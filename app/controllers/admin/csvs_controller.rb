require 'flink/reports/flinkers'

class Admin::CsvsController < Admin::AdminController
  
  def show
    if params[:export]
      CsvsWorker.perform_async
    else
      send_file Reports::Flinkers::CSV_FILE_PATH if File.exists?(Reports::Flinkers::CSV_FILE_PATH)
    end
  end
  
end
