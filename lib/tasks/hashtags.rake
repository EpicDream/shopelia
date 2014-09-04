namespace :flink do
  namespace :hashtags do
    
    desc "Import staff hashtags from csv"
    task :import => :environment do
      StaffHashtag.delete_all
      CSV.foreach("db/hashtags.csv", col_sep:";") do |row|
        category = row[2] if row[2] != "NA"
        visible = row[3] == "Visible"
        StaffHashtag.create!(name_fr:row[1], name_en:row[0], category:category, visible:visible)
      end
    end
  end
end