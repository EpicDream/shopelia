require "vinerb/version"
require "vinerb/error"
require 'vinerb/endpoints'
require "vinerb/model"
require "vinerb/api"
require 'debugger'

module AnneFashion
  class Vine
    include Vinerb
    include Vinerb::Model

    FOLLOW_TAGS = ["#lookbook", "#fashion", "#stylish"]
    CREDENTIALS = YAML.load_relative_file("accounts.yml")['vine']

    attr_reader :retrieve_following , :retrieve_followers, :retrieve_likes

    def initialize(account = "test")
      @messages = YAML.load_relative_file("vine_messages.yml")
      @user = Model::User.login(CREDENTIALS[account]['email'], CREDENTIALS[account]['password'])
      @api = @user.api
      retrieve_following
      retrieve_followers
      retrieve_likes
    end

    def vampirize_user(user_id)
      i = -1
      next_page = 0
      while i < next_page do
        p "Processing page n?" + next_page.to_s
        user_followers = @api.get_followers(user_id, {:size => "100", :page => next_page.to_s})
        unfollowed_people = user_followers.json['records'].map{|p| p unless is_following?(p['userId'])}.compact
        #p unfollowed_people
        unfollowed_people.each do |target|
          comment_follow_like_strategy(target["userId"],target["user"]["private"].to_i)
        end
        p "Finished page n?" + next_page.to_s
        i = next_page
        next_page = user_followers.json['nextPage']
      end
    end

    def follow_from_tag(tag_name)
      result = search(tag_name,{"size" => "33"})
      result.json['records'].each do |post|
          comment_follow_like_strategy(post["userId"],post['private'])
      end
    end

    def popular_page
      posts = get_popular_posts
      posts.json['records'].each do |post|
        comments = @api.get_comments(post["postId"])
        comments.json['records'].each do |comment|
          comment_follow_like_strategy(comment['userId'],comment['user']['private'])
        end
      end
    end

    def comment_follow_like_strategy(user_id,private)
      @some_posts = []
      unless is_following?(user_id) or  user_id == @api.user_id
        follow(user_id)
        if get_safely_user_timeline(user_id,private)
          like_posts
        end
      end
    end

    def like_posts
      @some_posts.each do |post|
         like(post["postId"])
       end
    end

    def search(tag_name,options = {})
      @api.get_tag_timeline(tag_name,options)
    end

    def unlike_liked
      @likes.json['records'].each do |like|
        unlike(like["postId"])
      end
    end

    #unfollow people that don't follow back
    def unfollow_followings
      garbage_users = @followings.json['records'].map{|p| p['userId'] unless is_follower?(p['userId']) }
      garbage_users.each do |user_id|
        unfollow(user_id)
      end
    end

    #follow user unless i'm already following him
    def follow(user_id)
      unless is_following?(user_id)
        @api.follow(user_id)
      end
    end

    #unfollow user only if i already follow him
    def unfollow(user_id)
      if is_following?(user_id)
        @api.unfollow(user_id)
      end
    end

    #like post only if not liked

    def like(post_id)
      unless is_liked?(post_id)
        @api.like(post_id)
      end
    end

    def unlike(post_id)
      if is_liked?(post_id)
        @api.unlike(post_id)
      end
    end

    def comment(post_id,comment)
      @api.comment(post_id, comment, {})
    end

    def get_popular_posts
      @api.get_popular_timeline
    end

    def get_safely_user_timeline(user_id,private, nb_posts = 2)
      res =  (private == 1)
      unless res
        @some_posts = @api.get_user_timeline(user_id, {"size" => nb_posts.to_s}).json['records']
      end
      !res
    end


    def retrieve_following
      @followings ||= @api.get_following(@api.user_id)
    end

    def retrieve_followers
      @followers ||= @api.get_followers(@api.user_id)
    end

    def retrieve_likes
      @likes = @api.get_user_likes(@api.user_id, {"size" => "100"})
    end

    def is_liked?(post_id)
      @likes.json['records'].map{|p| p['postId']}.include?(post_id.to_i)
    end

    def is_follower?(user_id)
      @followers.json['records'].map{|p| p['userId']}.include?(user_id.to_i)
    end

    def is_following?(user_id)
      @followings.json['records'].map{|p| p['userId']}.include?(user_id.to_i)
    end
  end
end
