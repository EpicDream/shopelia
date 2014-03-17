module Algolia
  module FlinkerSearch
  
    def self.included(klass)
      klass.class_eval do
        include AlgoliaSearch
        
        algoliasearch auto_index: true, per_environment: true, unless: :publisher_without_looks? do
          attribute :username, :name, :url, :email, :staff_pick
      
          attribute :avatar do
            Rails.configuration.avatar_host + self.avatar.url(:thumb, timestamp:true)
          end
    
          attribute :country do
            country.try(:iso) 
          end
    
          attribute :rank do
            display_order if self.is_publisher?
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
            [self.is_publisher? ? 'publisher' : 'non-publisher']
          end
    
          customRanking ['asc(username)', 'asc(name)']
          attributesToIndex ['username', 'name']
        end
        
        #TEMPORARY ALGOLIA QUICK PATCH
        private
        
        def algolia_perform_index_tasks
          return if !@algolia_auto_indexing || @algolia_must_reindex == false || @algolia_must_reindex.nil?
          algolia_index!
          remove_instance_variable(:@algolia_auto_indexing) if instance_variable_defined?(:@algolia_auto_indexing)
          remove_instance_variable(:@algolia_synchronous) if instance_variable_defined?(:@algolia_synchronous)
          remove_instance_variable(:@algolia_must_reindex) if instance_variable_defined?(:@algolia_must_reindex)
        end
        
      end
    end

  end
end