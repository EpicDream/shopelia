namespace :flink do
  namespace :newsletter do

    desc "Prepare cache of recommendations to avoid long running send newsletter to mailjet"
    task :prepare_cache => :environment do
      Flinker.where(newsletter:true).where("email !~ '@flink'").find_in_batches do |flinkers|
        flinkers.each { |flinker|
          Flinker.recommendations_for(flinker)
        }
      end
    end 
    
  end
end