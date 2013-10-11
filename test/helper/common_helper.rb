# -*- encoding : utf-8 -*-

module CommonHelper
  include Capybara::DSL

  def ensure_on(path)
    visit(path) unless current_path == path
  end
end