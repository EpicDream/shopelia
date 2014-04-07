require 'flink/reports/flinkers'

class Admin::CsvsController < Admin::AdminController
  
  def show
    Reports::Flinkers.export
    send_file Reports::Flinkers::CSV_FILE_PATH
  end
  
end
