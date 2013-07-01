namespace :shopelia do
  namespace :leetchi do
    
    desc "Create leetchi users and payment cards"
    task :create_objects => :environment do
      User.where(leetchi_id:nil).each do |user|
        user.create_leetchi
      end
      PaymentCard.where(leetchi_id:nil).each do |card|
        card.create_leetchi
      end
    end

  end
end
