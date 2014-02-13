module LeftronicStats
  class Stats
    def get_active_users_from(start_time)
      time = Time.now
      flinkers_count = Flinker.all.count.to_f
      nb_au = Flinker.where(:last_sign_in_at => start_time..time).count.to_f
      ((nb_au/flinkers_count) * 100).round(1)
    end
  end
end
