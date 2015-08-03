class ApplicationController < ActionController::API
  private
    def authenticate_user_from_token!
      nusnet_id = request.headers['nusnet_id']
      access_token = request.headers['access_token']
      access_token_digest = Digest::SHA2.base64digest(access_token)
      @user = User.where(nusnet_id: nusnet_id, access_token_digest: access_token_digest)
      if @user.blank?
        return generate_error_payload(401, 'Authorization failed.')
      end
    end

    def generator_error_payload(status, details)
      error = {
        status: status,
        details: details
      }

      Rails.logger.info do
        "[#{self.class}][#{__method__}] Failed. Parameters: #{params}. Error: #{error}"
      end

      render json: error, status: status
    end
end
