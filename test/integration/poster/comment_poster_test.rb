# encoding: UTF-8
require 'test_helper'
require 'poster/comment'

class Poster::CommentTest < ActiveSupport::TestCase
  COMMENT = "J'adore, vraiment tendance! Ca me donne des envies d'achat tout ça !"
  EMAIL = "anne.fashion.paris@gmail.com"
  NAME = "Anne de Paris"
  WEBSITE_URL = "http://flinker.fr"
  
  setup do
    @poster = Poster::Comment.new(comment:COMMENT, author:NAME, email:EMAIL)
  end
  
  test "include appropriate publisher module wordpress" do
    @poster.post_url = "http://www.leblogdebetty.com/new-stuff-17"
    assert @poster.respond_to?(:form)
    assert_equal Poster::Wordpress, @poster.publisher
  end
  
  test "include appropriate publisher module blogspot" do
    @poster.post_url = "http://1991-today.blogspot.fr/2013/12/come-back-to-me.html"
    assert @poster.respond_to?(:form)
    assert_equal Poster::Blogspot, @poster.publisher
  end
  
  test "include appropriate publisher module blogspot with popup" do
    skip
    @poster.post_url = "http://1finedai.blogspot.fr/2013/12/winter-pink.html"
    assert @poster.respond_to?(:form)
    assert_equal Poster::Blogspot, @poster.publisher
  end
  
  test "fill wordpress comment form" do
    @poster.post_url = "http://www.leblogdebetty.com/new-stuff-17"
    form = @poster.fill @poster.form
    
    assert_equal NAME, form['author']
    assert_equal EMAIL, form['email']
    assert_equal COMMENT, form['comment']
  end
  
  test "add wordpress token to comment if exists" do
    @poster.post_url = "http://www.larevuedekenza.fr/2013/12/essentiel-antwerp-2.html"
    form = @poster.fill @poster.form
    token = "381f36947bedfbda52041e209e9713db_1687"
    assert_equal "#{token} #{COMMENT}", form['comment']
  end
  
  test "deliver comment to wordpress site" do
    skip #OK COMMENT POSTED
    Incident.expects(:create).never
    @poster.post_url = "http://lepetitmondedejulie.net/2013/12/03/paris-1"
    assert @poster.deliver
  end
  
  test "deliver comment to wordpress site with no-javascript token" do
    skip #OK COMMENT POSTED
    comment = "381f36947bedfbda52041e209e9713db_1687 Super ! Des tenues originales. J'adore le pull"
    @poster = Poster::Comment.new(comment:comment, author:NAME, email:EMAIL)
    Incident.expects(:create).never
    @poster.post_url = "http://www.larevuedekenza.fr/2013/12/essentiel-antwerp-2.html"
    assert @poster.deliver
  end
  
  test "deliver comment to blogspot site" do
    skip #OK COMMENT POSTED
    comment = "Toujours ravissante. J'adore ce pantalon, je crois que je vais le commander au père noël:)"
    @poster = Poster::Comment.new(comment:comment, author:NAME, email:EMAIL)
    Incident.expects(:create).never
    @poster.post_url = "http://haveafashionbreak.blogspot.fr/2013/12/keep-walking.html"
    assert @poster.deliver
  end
  
  test "deliver comment to blogspot site 2" do
    skip #OK COMMENT POSTED
    comment = "Tu es magnifique, Super sexy ..."
    @poster = Poster::Comment.new(comment:comment, author:NAME, email:EMAIL)
    Incident.expects(:create).never
    @poster.post_url = "http://ledressingdeleeloo.blogspot.fr/2013/12/hipanema.html"
    assert @poster.deliver
  end

  test "deliver comment to blogspot site with comment popup mode" do
    skip #OK COMMENT POSTED
    comment = "Cette robe est vraiment top. Elle te va à ravir ! ... J'adore les robes courtes ...;)"
    @poster = Poster::Comment.new(comment:comment, author:NAME, email:EMAIL)
    Incident.expects(:create).never
    @poster.post_url = "http://www.maella-b.com/2013/12/barboteuse.html"
    assert @poster.deliver
  end
  
  test "deliver comment to blogspot site with comment popup mode 2" do
    skip #OK COMMENT POSTED
    comment = "J'adore le manteau, il a l'air très chaud en plus. Soigne toi bien !"
    @poster = Poster::Comment.new(comment:comment, author:NAME, email:EMAIL)
    Incident.expects(:create).never
    @poster.post_url = "http://www.maella-b.com/2013/12/jouer-froid-blog-bretagne.html"
    assert @poster.deliver
  end
  
  test "deliver commment blogspot site http://www.adenorah.com/2013/11/chanel.html" do
    skip #OK COMMENT POSTED
    comment = "Super joli. Le bleu te va à ravir."
    url = "http://www.adenorah.com/2014/01/stella-luna-look.html"
    @poster = Poster::Comment.new(comment:comment, author:NAME, email:EMAIL, post_url:url)
    Incident.expects(:create).never
    assert @poster.deliver
  end
  
  test "deliver commment wordpress site http://www.garancedore.fr/2013/12/16/rashida/" do
    skip #OK COMMENT POSTED
    comment = "J'aime beaucoup cette photo, bel arrangement. Cadrage nickel ;)"
    url = "http://www.garancedore.fr/2014/01/18/weekend-inspiration-138/"
    @poster = Poster::Comment.new(comment:comment, author:NAME, email:EMAIL, post_url:url)
    Incident.expects(:create).never
    assert @poster.deliver
  end
  
  test "deliver commment wordpress site http://kutchetcouture.com" do
    skip
    comment = "anoiaque. Somptueuse comme d'habitude! Sympa l'image animée. Que dire à part que tu es romantique à shouait ;) <br/> <a href='http://flink.io'>Flink</a>"
    url = "http://kutchetcouture.com/2014/01/29/impression-python/"
    @poster = Poster::Comment.new(comment:comment, author:"anoiaque", email:"flinkhq@gmail.com", post_url:url)
    Incident.expects(:create).never
    assert @poster.deliver
  end

end

  