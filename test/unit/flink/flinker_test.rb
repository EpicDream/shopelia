require 'test_helper'

class FlinkerTest < ActiveSupport::TestCase
  
  setup do
    @flinker = new_flinker
  end
  
  test "it should create flinker" do
    assert @flinker.save

    assert_equal 0, ActionMailer::Base.deliveries.count, "a confirmation email shouldn't have been sent"
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
  
  test "friends of flinkers : flinkers facebook friends U followings" do
    flinker = flinkers(:fanny)
    follow(flinkers(:nana), flinker)

    friends = flinker.friends

    assert_equal 3, friends.count
    assert_equal ["bettyusername", "nanausername", "Lilou"].to_set, friends.map(&:username).to_set
  end
  
  test "activities counts only looks published" do
    flinker = flinkers(:betty)
    flinker.looks.first.update_attributes(is_published:false)
    
    assert_equal 1, flinker.activities_counts["looks"]
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
    flinker = flinkers(:lilou)

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
  
  test "similars flinkers, who likes looks of same publishers" do
    FlinkerLike.destroy_all
    
    nana = flinkers(:nana)
    fanny = flinkers(:fanny)
    boop = flinkers(:boop)
    like(nana, [looks(:agadir), looks(:quimper)])
    like(fanny, [looks(:thaiti)])
    like(boop, [looks(:thaiti), looks(:quimper)])

    flinkers = Flinker.similar_to(nana)

    assert_equal [boop, fanny].to_set, flinkers.take(2).to_set
    assert_equal Flinker.count - 3, flinkers.count
  end
  
  test "trend setters, staff picked of flinker country plus most liked publishers to complete to 20" do
    Flinker.stubs(:top_liked).returns((1..18).map{stub})

    flinkers = Flinker.trend_setters(Country.fr)
    assert_equal 2, (flinkers & [flinkers(:betty), flinkers(:boop)]).count
    assert_equal 20, flinkers.count
  end
  
  test "trend setters for uk" do
    Flinker.stubs(:top_liked).returns((1..18).map{stub})
    
    flinkers = Flinker.trend_setters(Country.en)

    assert flinkers.include?(flinkers(:nana))
    assert !flinkers.include?(flinkers(:betty))
  end
  
  test "trend setters, staff picked of US if no staff picked in its country" do
    flinkers = Flinker.trend_setters(countries(:spain))

    assert flinkers.include?(flinkers(:anne))
  end
  
  test "trend setters, staff picked of US if no country set" do
    flinkers = Flinker.trend_setters(nil)

    assert flinkers.include?(flinkers(:anne))
  end
  
  test "stop auto follow staff picked if device build >= 31" do
    set_env_user_agent(31)
    FlinkerFollow.any_instance.expects(:create).never
    
    @flinker.save
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