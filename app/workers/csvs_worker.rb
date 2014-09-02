require 'flink/reports/flinkers'

class CsvsWorker
  include Sidekiq::Worker
  
  def perform
    Reports::Flinkers.export
  end
end
