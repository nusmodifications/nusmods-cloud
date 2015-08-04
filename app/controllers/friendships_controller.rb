class FriendshipsController < ApplicationController
  def index
    friendships = FriendshipsSerializer.new(@user)
    generate_api_payload('friendships', friendships)
  end

  def create
    friend = User.find_by_nusnet_id(friendship_params[:friendNusnetId])
    return generate_error_payload('Not found', 404, 'Friend not registered.') if friend.blank?

    active_friendship = Friendship.where(user_id: @user.id, friend_id: friend.id)
    passive_friendship = Friendship.where(user_id: friend.id, friend_id: @user.id)

    if active_friendship.present? || passive_friendship.present?
      friendship = active_friendship.first || passive_friendship.first
      if friendship.approved
        return generate_error_payload('Bad request', 400, "User #{params[:friendNusnetId]} is already your friend.")
      elsif friendship.user_id == @user.id
        return generate_error_payload('Bad request', 400, 'Friend request already sent.')
      else
        friendship.update_attribute(:approved, true)
        return generate_api_payload('friendProfile', FriendProfileSerializer.new(friend))
      end
    end

    if Friendship.create(user_id: @user.id, friend_id: friend.id)
      generate_api_payload('outgoingRequest', OutgoingRequestSerializer.new(friend))
    else
      generate_error_payload('Bad request', 400, 'Failed to add friend.')
    end
  end

  def delete
    friend = User.find_by_nusnet_id(friendship_params[:friendNusnetId])
    return generate_error_payload('Not found', 404, 'Friend not found.') if friend.blank?

    active_friendship = Friendship.where(user_id: @user.id, friend_id: friend.id)
    passive_friendship = Friendship.where(user_id: friend.id, friend_id: @user.id)

    if active_friendship.blank? && passive_friendship.blank?
      return generate_error_payload('Not found', 404, 'Friendship not found')
    end

    friendship = active_friendship.first || passive_friendship.first
    if friendship.destroy
      if friendship.approved
        return generate_api_payload('deleted')
      elsif friendship.user_id == @user.id
        return generate_api_payload('cancelled')
      else
        return generate_api_payload('rejected')
      end
    else
      generate_error_payload('')
    end
  end

  private
    def friendship_params
      params.require(:friendNusnetId)
      params.permit(:friendNusnetId, :approved)
    end
end
