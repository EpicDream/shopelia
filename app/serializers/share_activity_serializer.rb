class ShareActivitySerializer < ActivitySerializer
  attributes :social_network
  
  def social_network
    object.resource.social_network.name
  end
end
 