Rake::TestTask.new('test:flink') do |t|
  t.libs << "test"
  t.test_files = FileList['test/unit/flink/**/*_test.rb', 'test/functional/api/flink/**/*_test.rb']
  t.verbose = false
end