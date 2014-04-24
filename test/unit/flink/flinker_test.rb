require 'test_helper'

class FlinkerTest < ActiveSupport::TestCase
  
  setup do
    @flinker = new_flinker
  end
  
  test "it should create flinker" do
    assert @flinker.save

    assert_equal 0, ActionMailer::Base.deliveries.count, "a confirmation email shouldn't have been sent"
  end

  test "it should auto follow staff picked flinkers of same country or universal" do 
    assert_difference "FlinkerFollow.count", 3 do
      @flinker.save
    end
  end
  
  test "it should auto follow staff picked flinkers of same country more universal flinkers if ones" do 
    flinker = Flinker.new(attributes.merge({email:"univ@me.com", name:"Universal", universal:true, country_iso:'GB', staff_pick:true}))
    assert flinker.save!

    assert_difference "FlinkerFollow.count", 4 do
      @flinker.save
    end
  end
  
  test "when name change, it should be changed on blog" do
    flinker = flinkers(:elarch)
    blog = blogs(:betty) and blog.flinker_id = flinker.id
    
    assert blog.save
    assert flinker.update_attributes(name:"Toto") and blog.reload
    assert_equal "Toto", flinker.name
    assert_equal "Toto", blog.name
  end
  
  test "assign country from country_iso transcient attribute" do
    flinker = Flinker.new(email:"test@flink.io", username:"flink", password:"toto1234", password_confirmation:"toto1234", country_iso:"fr")
    
    assert flinker.save!
    assert_equal countries(:france), flinker.country
  end
  
  test "of_country scope case insensitive on iso code" do
    assert_equal Flinker.of_country("fr"), Flinker.of_country("FR") 
  end
  
  test "it should auto follow french staff picked flinkers if none of its country" do 
    @flinker.country_id = countries(:morocco).id

    assert_difference "FlinkerFollow.count", 3 do
      @flinker.save
    end
  end
  
  test "friends of flinkers : flinkers facebook friends U followings" do
    #3 followings friends + 1 from facebook + 1 (followings + facebook)
    flinker = flinkers(:fanny)
    flinker.send(:follow_staff_picked) 

    friends = flinker.friends

    assert_equal 4, friends.count
    assert_equal ["boop", "bettyusername", "nanausername", "Lilou"].to_set, friends.map(&:username).to_set
  end
  
  test "activities counts only looks published" do
    flinker = flinkers(:betty)
    flinker.looks.first.update_attributes(is_published:false)
    
    assert_equal 0, flinker.activities_counts["looks"]
  end
  
  test "username must only contain (. or letter or digit or - or _)" do
    flinker = new_flinker
    flinker.username = "Anne de Paris"
    
    assert !flinker.save
    assert flinker.errors.messages[:username]
  end
  
  test "with blog name or url matching pattern" do
    publishers = Flinker.with_blog_matching("blog")
    
    assert_equal 1, publishers.count
    assert_equal flinkers(:betty), publishers.first
  end
  
  test "destroy" do
    betty_id = flinkers(:betty).id
    Activity.create!(flinker_id:flinkers(:boop).id, target_id:betty_id)
    FlinkerFollow.create!(flinker_id:flinkers(:boop).id, follow_id:betty_id)
    FacebookFriend.create!(flinker_id:flinkers(:boop).id, friend_flinker_id:betty_id, identifier:"hhhdd", name:'bop')
    
    assert flinkers(:betty).destroy
    
    assert_equal 0, Activity.where(target_id:betty_id).count
    assert_equal 0, FlinkerFollow.where(follow_id:betty_id).count
    assert_equal 0, FacebookFriend.where(friend_flinker_id:betty_id).count
    assert_equal 0, Blog.where(flinker_id:betty_id).count
  end
  
  test "username uniqueness case insensitive" do
    flinker = new_flinker
    flinker.username = "LiloU"

    assert !flinker.save
  end
  
  test "remove from flinker algolia index if no more looks" do
    flinker = flinkers(:betty)

    assert_equal 1, flinker.looks.published.count
    Flinker.any_instance.expects(:remove_from_index!)
    look = flinker.looks.first
    
    look.is_published = false
    look.save
  end

  test "algolia index flinker algolia if she become with look published" do
    Look.update_all(is_published:false)
    flinker = flinkers(:betty)
    
    assert_equal 0, flinker.looks.published.count
    Flinker.any_instance.expects(:index!)
    look = flinker.looks.first
    
    look.is_published = true
    look.save
  end
  
  test "assign uuid on create" do
    flinker = new_flinker
    
    assert flinker.save
    assert flinker.uuid && flinker.uuid.size == 8
  end
  
  private

  def new_flinker
    Flinker.new(attributes)
  end 
  
  def attributes
    { name:"Name",
      url:"http://www.url.to",
      is_publisher:true,
      email:"test@flink.io",
      password:"password",
      country_id:countries(:france).id,
      password_confirmation:"password"}
  end
  
end