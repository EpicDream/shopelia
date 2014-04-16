class FlinkerMerge
  MAP_BACKUP_PATH = "/tmp/flinkers_merge.yml"
  ATTRIBUTES = [:email, :country_id, :lang_iso, :encrypted_password, :authentication_token]
  KLASSES = [FlinkerLike, Comment, FlinkerFollow, Device, Activity, FacebookFriend, FlinkerAuthentication]
  
  def initialize(flinker, target)
    @flinker = flinker
    @target = target
    File.open(MAP_BACKUP_PATH, "a+") { |file| file.write("#{@flinker.id}: #{@target.id}\n")  }
  end
  
  def merge
    ActiveRecord::Base.transaction do
      ATTRIBUTES.each {|attr| @target.send("#{attr}=", @flinker.send(attr)) }
      
      KLASSES.each do |klass|
        klass.where(flinker_id:@flinker.id).update_all(flinker_id:@target.id)
      end
      
      FlinkerFollow.where(follow_id:@flinker.id).update_all(follow_id:@target.id)
      Activity.where(target_id:@flinker.id).update_all(target_id:@target.id)
      FacebookFriend.where(friend_flinker_id:@flinker.id).update_all(friend_flinker_id:@target.id)
      FlinkerFollow.where(flinker_id:@target.id, follow_id:@target.id).destroy_all

      @flinker.email += "--"
      @flinker.authentication_token += "--"
      @flinker.save!
      
      @target.save!
    end
  end
  
  def self.merge_from_csv csv_path, col_sep=";"
    CSV.foreach(csv_path, col_sep:col_sep) do |row|
      next unless row[0] && row[1]
      url, email = row[0].gsub!(/\/$/, '').strip, row[1].strip
      host = URI.parse(url).host
      
      targets = Flinker.where('url ~* ? or url ~*', host, host.gsub(/www\./, ''))
      flinkers = Flinker.where(email:email)
      
      unless targets.count == 1
        puts "Many flinker with url #{url}, SKIPPED" if flinkers.count > 1
        puts "Flinker with url #{url} not found, SKIPPED" if flinkers.count == 0
        next
      end
      
      unless flinkers.count == 1
        puts "Many flinkers with email : #{email}, SKIPPED" if targets.count > 1
        puts "Flinker with email : #{email} not found, SKIPPED" if targets.count == 0
        next
      end
      
      target = targets.first
      flinker = flinkers.first
      
      if flinker == target
        puts "WARNING : Same flinker/target, SKIPPED"
        next
      end
      
      new(flinker, target).merge
    end
    
  end
end