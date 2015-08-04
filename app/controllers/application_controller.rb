class ApplicationController < ActionController::API
  include ActionController::Serialization

  before_filter :authenticate_user_from_token!

  rescue_from(ActionController::ParameterMissing) do |e|
    generate_error_payload(400, "Parameter `#{e.param}` is missing.")
  end

  private
    def authenticate_user_from_token!
      nusnet_id = params[:nusnetId]
      access_token = request.headers['Authorization']
      @user = User.where(nusnet_id: nusnet_id, access_token: access_token).first
      if @user.blank?
        return generate_error_payload(401, 'YOU SHALL NOT PASS!')
      end
    end

    def generate_api_payload(type, data)
      payload = { type: type, data: data }

      render json: payload, status: :ok
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
