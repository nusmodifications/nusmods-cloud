class ApplicationController < ActionController::API
  include ActionController::Serialization

  private
    def authenticate_user_from_token!
      nusnet_id = request.headers['nusnet_id']
      access_token = request.headers['access_token']
      @user = User.where(nusnet_id: nusnet_id, access_token: access_token)
      if @user.blank?
        return generate_error_payload(401, 'YOU SHALL NOT PASS!')
      end
    end

    def generate_error_payload(status, details)
      error = {
        status: status,
        details: details
      }

      Rails.logger.info do
        "[#{self.class}][#{self.action_name}] Failed. Parameters: #{params}. Error: #{error}"
      end

      render json: error, status: status
    end
end
