require "nokogiri"
require "base64"
require "digest/sha1"
require "openssl"

class VSigner
  SECURITY_XSD_URL = "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"
  SECURITY_UTILITY_URL = "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"
  SIGNATURE_NAMESPACE_URL = "http://www.w3.org/2000/09/xmldsig#"
  SIGNED_INFO_NAMESPACE_URL = 'http://www.w3.org/2000/09/xmldsig#'
  CANONICALIZATION_NAMESPACE_URL = 'http://www.w3.org/2001/10/xml-exc-c14n#'
  SIGNATURE_ALGORITHM_URL = 'http://www.w3.org/2000/09/xmldsig#rsa-sha1'
  
  attr_accessor :document, :cert, :private_key, :security_token_id
  attr_writer :security_node

  def initialize(document)
    self.document = Nokogiri::XML(document.to_s, &:noblanks)
  end

  def to_xml
    document.to_xml(:save_with => 0)
  end

  def security_node
    @security_node ||= document.xpath("//o:Security", "o" => SECURITY_XSD_URL).first
  end

  def canonicalize(node = document)
    node.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0)
  end
 
  def signature_node
    unless node = document.xpath("//ds:Signature", "ds" => SIGNATURE_NAMESPACE_URL).first
      node = Nokogiri::XML::Node.new('Signature', document)
      node.default_namespace = SIGNATURE_NAMESPACE_URL
      security_node.add_child(node)
    end
    node
  end

  def signed_info_node
    unless node = signature_node.xpath("//ds:SignedInfo", "ds" => SIGNED_INFO_NAMESPACE_URL).first
      node = Nokogiri::XML::Node.new('SignedInfo', document)
      signature_node.add_child(node)
      canonicalization_method_node = Nokogiri::XML::Node.new('CanonicalizationMethod', document)
      canonicalization_method_node['Algorithm'] = CANONICALIZATION_NAMESPACE_URL
      node.add_child(canonicalization_method_node)
      signature_method_node = Nokogiri::XML::Node.new('SignatureMethod', document)
      signature_method_node['Algorithm'] = SIGNATURE_ALGORITHM_URL
      node.add_child(signature_method_node)
    end
    node
  end

  def binary_security_token_node
    node = document.xpath("//o:BinarySecurityToken", "o" => "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd").first
    unless node
      node = Nokogiri::XML::Node.new('BinarySecurityToken', document)
      node['wsu:Id']         = security_token_id
      node['ValueType']    = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-x509-token-profile-1.0#X509v3'
      node['EncodingType'] = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary'
      node['xmlns:wsu'] = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'
      node.content = Base64.encode64(cert.to_der).gsub("\n", '')
      signature_node.add_previous_sibling(node)
      key_info_node = Nokogiri::XML::Node.new('KeyInfo', document)
      security_token_reference_node = Nokogiri::XML::Node.new('wsse:SecurityTokenReference', document)
      key_info_node.add_child(security_token_reference_node)
      reference_node = Nokogiri::XML::Node.new('wsse:Reference', document)
      reference_node['ValueType'] = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-x509-token-profile-1.0#X509v3'
      reference_node['URI'] = "##{security_token_id}"
      security_token_reference_node.add_child(reference_node)
      signed_info_node.add_next_sibling(key_info_node)
    end
    node
  end

  def digest!(target_node, options = {})
    id = options[:id]
    target_node['wsu:Id'] = id if id.size > 0
    target_canon = canonicalize(target_node)
    target_digest = Base64.encode64(OpenSSL::Digest::SHA1.digest(target_canon)).strip

    reference_node = Nokogiri::XML::Node.new('Reference', document)
    reference_node['URI'] = id.size > 0 ? "##{id}" : ""
    signed_info_node.add_child(reference_node)

    transforms_node = Nokogiri::XML::Node.new('Transforms', document)
    reference_node.add_child(transforms_node)

    transform_node = Nokogiri::XML::Node.new('Transform', document)
    if options[:enveloped]
      transform_node['Algorithm'] = 'http://www.w3.org/2000/09/xmldsig#enveloped-signature'
    else
      transform_node['Algorithm'] = 'http://www.w3.org/2001/10/xml-exc-c14n#'
    end
    transforms_node.add_child(transform_node)

    digest_method_node = Nokogiri::XML::Node.new('DigestMethod', document)
    digest_method_node['Algorithm'] = 'http://www.w3.org/2000/09/xmldsig#sha1'
    reference_node.add_child(digest_method_node)

    digest_value_node = Nokogiri::XML::Node.new('DigestValue', document)
    digest_value_node.content = target_digest
    reference_node.add_child(digest_value_node)
    self
  end

  def sign!(options = {})
    binary_security_token_node
    signed_info_canon = canonicalize(signed_info_node)

    signature = private_key.sign(OpenSSL::Digest::SHA1.new, signed_info_canon)
    signature_value_digest = Base64.encode64(signature).gsub("\n", '')

    signature_value_node = Nokogiri::XML::Node.new('SignatureValue', document)
    signature_value_node.content = signature_value_digest
    signed_info_node.add_next_sibling(signature_value_node)
    self
  end
 
  def timestamp!
    node = Nokogiri::XML::Node.new('wsu:Timestamp', document)
    node.add_namespace_definition('wsu', SECURITY_UTILITY_URL)
    node['wsu:Id'] = "Timestamp-#{Random.rand(100_000_000)}"
    created = Nokogiri::XML::Node.new('wsu:Created', document)
    created['xmlns:wsu'] = SECURITY_UTILITY_URL
    created.content = (Time.now - 10.seconds).gmtime.iso8601(3)
    node.add_child(created)
    expires = Nokogiri::XML::Node.new('wsu:Expires', document)
    expires['xmlns:wsu'] = SECURITY_UTILITY_URL
    expires.content = (Time.now + 5.minutes).gmtime.iso8601(3)
    node.add_child(expires)
    security_node.add_child(node)
    node
 end
end
