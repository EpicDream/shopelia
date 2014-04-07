module Reports
  class Flinkers
    CSV_FILE_PATH = "#{Rails.root}/public/flinkers.csv"
    HEADERS = ["ID", "USERNAME", "PUBLISHER", "FB_AUTH", "FB_AUTH_ONLY", "CREATED_AT"]
    
    def self.export
      csv = CSV.open(CSV_FILE_PATH, "w+")
      csv << HEADERS
      Flinker.includes(:flinker_authentications).find_in_batches do |flinkers|
        flinkers.each do |f|
          auth = f.flinker_authentications.first
          fb_auth = f.password.nil?
          csv << [f.id, f.username, f.is_publisher, auth.present?, fb_auth, f.created_at.to_s(:db)]
        end
      end
      csv.close
    end
  
  end
end