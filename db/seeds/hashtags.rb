names = LookProduct.select("distinct brand").map(&:brand).compact
names += LookProduct.codes.map { |code| 
  [:en, :fr].map { |locale| I18n.t("flink.products.#{code}", locale: locale) }
}.flatten

#create hashtags from all look products codes and brands
names.each { |name|
  Hashtag.create(name:name)
}

#create hashtags from look products codes and brands and assign hashtags to related looks
LookProduct.find_in_batches { |products|  
  products.map(&:create_hashtags_and_assign_to_look)
}

#create hashtags from comments and assign hashtags to related looks
Comment.find_in_batches { |comments|  
  comments.map(&:create_hashtags_and_assign_to_look)
}
