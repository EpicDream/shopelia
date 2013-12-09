# encoding: UTF-8
require 'test__helper'
require 'poster/comment'

class Poster::CommentTest < ActiveSupport::TestCase
  COMMENT = "J'adore, vraiment tendance! Ca me donne des envies d'achat tout ça !"
  EMAIL = "anne.paris@free.fr"
  NAME = "Anne de Paris"
  
  setup do
    @poster = Poster::Comment.new(COMMENT, NAME, EMAIL)
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
  
  test "fill worpress comment form" do
    @poster.url = "http://www.leblogdebetty.com/new-stuff-17"
    form = @poster.fill @poster.form
    
    assert_equal NAME, form['author']
    assert_equal EMAIL, form['email']
    assert_equal COMMENT, form['comment']
  end
  
  test "deliver comment" do
    skip
    Incident.expects(:create).never
    @poster.url = "http://lepetitmondedejulie.net/2013/12/03/paris-1"
    assert @poster.deliver
  end

end

  