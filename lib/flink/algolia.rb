module Algolia
  module FlinkerSearch
  
    def self.included(klass)
      klass.class_eval do
        include AlgoliaSearch
        
        algoliasearch auto_index: false, per_environment: true do
          attribute :username, :name, :url, :email, :staff_pick
      
          attribute :avatar do
            Rails.configuration.avatar_host + self.avatar.url(:thumb, timestamp:true)
          end
    
          attribute :country do
             country.try(:iso) 
           end
    
          attribute :rank do
            display_order
          end
    
          attribute :publisher do
            is_publisher
          end
    
          attribute :likes_count do 
            activities_counts["likes"]
          end
    
          attribute :follows_count do 
            activities_counts["followings"]
          end
    
          attribute :looks_count do 
            activities_counts["looks"]
          end
    
          attribute :comments_count do 
            activities_counts["comments"]
          end
      
          attribute :followed_count do 
            activities_counts["followed"]
          end
    
          attribute :liked_count do 
            FlinkerLike.liked_for(self).count if self.is_publisher? 
          end
    
          tags do
            [is_publisher? ? 'publisher' : 'non-publisher']
          end
    
          customRanking ['asc(username)', 'asc(name)']
          attributesToIndex ['username', 'name']
        end
      end
    end

  end
end