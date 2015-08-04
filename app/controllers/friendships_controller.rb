class FriendshipsController < ApplicationController
  def index
    friendships = FriendshipsSerializer.new(@user)
    generate_api_payload('friendships', friendships)
  end
end
