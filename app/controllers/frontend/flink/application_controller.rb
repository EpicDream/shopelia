class Frontend::Flink::ApplicationController < ApplicationController

  layout 'flink'

  def self.menu mode
    @@menu_mode = mode
  end

  def initialize_menu
    @menu_mode = @@menu_mode
  end

  menu :visible
  before_filter :initialize_menu

end