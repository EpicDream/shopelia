namespace :assets do
  
  desc "assets:precompile + assets:clean_expired"
  task :precompile_and_clean => ['assets:precompile', 'assets:clean_expired']
  
end

