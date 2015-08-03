class FriendshipsController < ApplicationController
  def index
    render json: @user, serializer: FriendshipsSerializer
  end
end
