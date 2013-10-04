# -*- encoding : utf-8 -*-
require 'test_helper'
class VirtualisTest < ActiveSupport::TestCase

  def test_virtualis_message_detail_carte_virtuelle
    params = {contrat:'CA13510136', efs:'02', identifiant:'55366600', reference:'5132685243999081503'}
    message = Virtualis::Message.new(:detail_carte_virtuelle, params).to_xml

    expected_xml = '<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
   <soap:Header>
      <wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" soap:mustUnderstand="1">
      </wsse:Security>
   </soap:Header>
   <soap:Body xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
      <ns1:detailCarteVirtuelle xmlns:ns1="http://webservice.virtualis.gicm.net/">
         <detailCarteVirtuelleBean>
            <contrat>CA13510136</contrat>
            <efs>02</efs>
            <identifiant>55366600</identifiant>
            <reference>5132685243999081503</reference>
         </detailCarteVirtuelleBean>
      </ns1:detailCarteVirtuelle>
   </soap:Body>
</soap:Envelope>'

    assert_equal expected_xml, message
  end

  def test_virtualis_card_invalid_params
    result = Virtualis::Card.create({montant:'AAA', duree:'2'})
    unless result['error_str'] =~ /Invalid reply received from server/
      assert_equal('error', result['status'])
      assert_equal("Invalid param montant: AAA", result['error_str'])
    end

    result = Virtualis::Card.detail({})
    unless result['error_str'] =~ /Invalid reply received from server/
      assert_equal('error', result['status'])
      assert_equal("Missing card reference", result['error_str'])
    end
  end

  def test_virtualis_card_lifecycle
    result = Virtualis::Card.create({montant:'2000', duree:'2'})
    unless result['error_str'] =~ /Invalid reply received from server/
      assert_equal('ok', result['status'], result['error_str'])

      card_reference = result['numeroReference']

      result = Virtualis::Card.detail({reference: card_reference})
      assert_equal('ok', result['status'], result['error_str'])

      result = Virtualis::Card.cancel({reference: card_reference})
      assert_equal('ok', result['status'], result['error_str'])

      result = Virtualis::Card.cancel({reference: card_reference})
      assert_equal('error', result['status'])
      assert_equal('8', result['resultat'])
    end
  end

  def test_virtualis_good_reports
    data = Virtualis::Report.parse("#{Rails.root}/test/data/virtualis/report_ok_1.csv")
    assert_equal(27, data[:creation].size)
    assert_equal(25, data[:authorization].size)
    assert_equal(0, data[:compensation].size)
    data = Virtualis::Report.parse("#{Rails.root}/test/data/virtualis/report_ok_2.csv")
    assert_equal(66, data[:creation].size)
    assert_equal(82, data[:authorization].size)
    assert_equal(83, data[:compensation].size)
  end
  
  def test_virtualis_broken_reports
    data = Virtualis::Report.parse("#{Rails.root}/test/data/virtualis/report_ko_1.csv")
    assert_equal(1, data[:errors].size)
    data = Virtualis::Report.parse("#{Rails.root}/test/data/virtualis/report_ko_2.csv")
    assert_equal(1, data[:errors].size)
  end

end
