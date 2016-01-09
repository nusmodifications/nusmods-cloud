class UsersController < ApplicationController
  skip_before_filter :authenticate_user_from_token!, only: :create

  def create
    profile = IVLE.new(auth_params[:ivleToken]).get_profile
    unless profile.present?
      return generate_error_payload('Unauthorized', 401, 'Your token is not my token.')
    end

    user = User.find_by_nusnet_id(profile[:nusnet_id]) || User.new
    user.assign_attributes(profile)
    user.access_token = Digest::SHA2.base64digest(profile[:ivle_token])

    if user.save
      generate_api_payload('userProfile', UserProfileSerializer.new(user))
    else
      generate_error_payload('Bad request', 400, 'Failed to login. Please contact support.')
    end
  end

  def show
    generate_api_payload('userProfile', UserProfileSerializer.new(@user))
  end

  private
    def auth_params
      params.require(:ivleToken)
      params.permit(:nusnetId, :ivleToken)
    end
end
