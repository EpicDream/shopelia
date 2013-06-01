# -*- encoding : utf-8 -*-
module ApplicationHelper

  def sortable(column, title = nil)
    title ||= column.titleize
    direction_marker = column == sort_column ? sort_direction == "asc" ? " ▲" : " ▼" : ""
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title + direction_marker, {:sort => column, :direction => direction}
  end

end
