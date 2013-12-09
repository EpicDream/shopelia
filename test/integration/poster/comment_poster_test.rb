# encoding: UTF-8
require 'test__helper'
require 'poster/comment'

class Poster::CommentTest < ActiveSupport::TestCase
  MESSAGE = "J'adore, vraiment tendance! Ca me donne des envies d'achat tout ça !"
  EMAIL = "caroline@yopmail.com"
  
  setup do
    @poster = Poster::Comment.new(MESSAGE)
  end
  
  test "include appropriate publisher module" do
    @poster.url = "http://www.leblogdebetty.com/new-stuff-17"
    assert @poster.respond_to?(:form)
    assert_equal Poster::Wordpress, @poster.publisher
  end
  
  test "create incident if publisher not found" do
    Incident.expects(:create)
    @poster.url = "http://www.prixing.fr"
  end

end

  