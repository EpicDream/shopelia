class PrivateMessageActivitySerializer < ActivitySerializer
  attributes :content
  
  def content
    object.resource.content
  end
end
