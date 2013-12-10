# encoding: UTF-8
require 'test__helper'
require 'poster/comment'

class Poster::CommentTest < ActiveSupport::TestCase
  COMMENT = "J'adore, vraiment tendance! Ca me donne des envies d'achat tout ça !"
  EMAIL = "anne.paris@free.fr"
  NAME = "Anne de Paris"
  WEBSITE_URL = "http://flinker.fr"
  
  setup do
    @poster = Poster::Comment.new(comment:COMMENT, author:NAME, email:EMAIL)
  end
  
  test "include appropriate publisher module wordpress" do
    @poster.url = "http://www.leblogdebetty.com/new-stuff-17"
    assert @poster.respond_to?(:form)
    assert_equal Poster::Wordpress, @poster.publisher
  end
  
  test "include appropriate publisher module blogspot" do
    @poster.url = "http://1991-today.blogspot.fr/2013/12/come-back-to-me.html"
    assert @poster.respond_to?(:form)
    assert_equal Poster::Blogspot, @poster.publisher
  end
  
  test "create incident if publisher not found" do
    Incident.expects(:create)
    @poster.url = "http://www.prixing.fr"
  end
  
  test "fill wordpress comment form" do
    @poster.url = "http://www.leblogdebetty.com/new-stuff-17"
    form = @poster.fill @poster.form
    
    assert_equal NAME, form['author']
    assert_equal EMAIL, form['email']
    assert_equal COMMENT, form['comment']
  end
  
  test "fill blogspot comment form" do
    @poster.url = "http://1991-today.blogspot.fr/2013/12/come-back-to-me.html"
    @poster.website_url = WEBSITE_URL
    form = @poster.fill @poster.form
    
    assert_equal "#{COMMENT} - #{WEBSITE_URL}", form['commentBody']
  end
  
  test "deliver comment to wordpress site" do
    skip
    Incident.expects(:create).never
    @poster.url = "http://lepetitmondedejulie.net/2013/12/03/paris-1"
    assert @poster.deliver
  end
  
  test "deliver comment to blogspot site" do
    skip
    comment = "+1 Cette robe est vraiment top. Je crois que je vais casser ma tirelire.."
    @poster = Poster::Comment.new(comment, NAME, EMAIL)
    Incident.expects(:create).never
    @poster.url = "http://1991-today.blogspot.fr/2013/12/nobody-ever-stops-me.html"
    assert @poster.deliver
  end

end

  