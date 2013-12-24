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

    attr_reader :retrieve_following , :retrieve_followers, :retrieve_likes
    def initialize(email, password)
      @messages = YAML.load_relative_file("vine_messages.yml")
      @user = Model::User.login(email, password)
      @api = @user.api
      retrieve_following
      retrieve_followers
      retrieve_likes
    end

    def follow_from_tag(tag_name)
      result = search(tag_name,{"size" => "33"})
      result.json['records'].each do |post|
        comment_follow_like_strategy(post["userId"],nb_posts = 3)
      end
    end

    def popular_page
      posts = get_popular_posts
      posts.json['records'].each do |post|
        comments = @api.get_comments(post["postId"])
        comments.json['records'].each do |comment|
          comment_follow_like_strategy(comment['userId'],nb_posts = 3)
        end
      end
    end

    def comment_follow_like_strategy(user_id,nb_posts = 3)
      @some_posts = nil
      follow(user_id)
      retrieve_posts_from(user_id, nb_posts)
      like_posts
      comment_on_posts
    end


    def retrieve_posts_from(user_id, nb_posts = 3)
       @some_posts = @api.get_user_timeline(user_id, {"size" => nb_posts.to_s}).json['records']
    end

    def like_posts
      @some_posts.each do |post|
         like(post["postId"])
       end
    end

    def comment_on_posts
      message = @messages.sample
      #message = @messages.sample and @messages.delete(message)
      @some_posts.each do |post|
        comment(post["postId"],message)
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
