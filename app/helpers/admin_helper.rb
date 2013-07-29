module AdminHelper

  def incidents_count
    count = Incident.where(processed:false).count
    count > 0 ? " <strong>(#{count})</strong>" : ""
  end
  
  def incident_severity_to_html s
    if s == Incident::INFORMATIVE 
      '<span class="label label-info">Info</span>'
    elsif s == Incident::IMPORTANT 
      '<span class="label label-warning">Important</span>'
    elsif s == Incident::CRITICAL 
      '<span class="label label-danger">Critical</span>'
    end
  end

end
