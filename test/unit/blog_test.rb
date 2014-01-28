require 'test_helper'

class BlogTest < ActiveSupport::TestCase
  
  test "create flinker and assign to blog if none" do
    blog = Blog.create(url:"http://fashion.fr",country:"FR",avatar_url:"http://cdn10.lbstatic.nu/files/users/small/2701077_IMG_83752.jpg")
    
    assert blog.flinker
    assert blog.flinker.is_publisher?
    assert_equal countries(:france).id, blog.flinker.country_id
    assert blog.flinker.avatar_file_name.present?
  end
  
  test "do not assign new flinker if blog created with flinker reference" do
    flinker = Flinker.create(name:"fashion", url:"http://fashion.fr", email:"toto@flinker.io", password:"password", password_confirmation:"password")
    
    Flinker.expects(:create).never
    blog = Blog.create(url:"http://fashion.fr", flinker_id:flinker.id)
    
    assert_equal flinker, blog.flinker
  end
  
  test "uniqueness on url with slash tail" do
    assert Blog.create(url:"http://miss.com")
    
    assert_difference('Blog.count', 0) do
      Blog.create(url:"http://miss.com/")
    end
  end
  
  test "when a blog is skipped, it should not be scraped" do
    blog = Blog.create(url:"http://fashion.fr")
    assert blog.scraped?
    assert !blog.skipped?
    
    blog.update_attributes(skipped:true)
    
    assert !blog.scraped?
    assert blog.skipped?
  end
  
  test "when a blog is set to scraped, it should not be skipped" do
    blog = Blog.create(url:"http://fashion.fr", scraped:false, skipped:true)
    assert !blog.scraped?
    assert blog.skipped?
    
    blog.update_attributes(scraped:true)
    
    assert blog.scraped?
    assert !blog.skipped?
  end
  
  test "if avatar url is updated, flinker avatar image must be updated" do
    blog = Blog.create(url:"http://fashion.fr", scraped:false, skipped:true)
    
    blog.flinker.expects(:set_avatar)
    blog.update_attributes(avatar_url:'http://www.superimage.com/image.png')
    assert_equal "http://www.superimage.com/image.png", blog.flinker.avatar_url
  end
  
  test "when blog name is updated, it should update flinker name" do
    blog = Blog.create(url:"http://fashion.fr", name:"Anne")
    assert_equal "Anne", blog.flinker.name
    
    blog.update_attributes(name:"Marie")
    assert_equal "Marie", blog.reload.flinker.name
  end
  
end
