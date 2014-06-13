module Blogs
  class Updater

    def initialize csv_path
      @csv_path = csv_path
      Rails.logger = Logger.new("log/blogs_update.log")
    end
    
    def run
      return unless continue?
      CSV.foreach(@csv_path, col_sep: ';') do |row|
        begin
          report(row[0], "Missing ID") and next unless blog = Blog.where(id:row[0]).includes(:flinker).first
          flinker = blog.flinker
          if row[8] =~ /SUPP/
            blog.destroy
            flinker.destroy
            report(row[0], "Destroyed")
            next
          end
          blog.update_attributes!(name: row[2].strip, url: row[5].strip, country: row[7].strip)
          flinker.update_attributes!(username: row[4].strip)
        rescue => e
          report(row[0], e.inspect)
        end
      end    
    end
    
    def continue?
      puts "WARNING: La première colonne(0) doit être l'ID du blog. Continuer ? (y/n)"
      gets.chomp == "y"
    end
    
    def report id, message=nil
      Rails.logger.error "ID : #{id} - #{message}\n"
    end
  end
end