if ENV['RAILS_SEED']
  load(Rails.root.join( 'db', 'seeds', "#{ENV['RAILS_SEED']}.rb"))
else
  $stdout << "---- Usage -----\n\n"
  $stdout << "rake db:seed RAILS_SEED=<mon_seed>"
end
