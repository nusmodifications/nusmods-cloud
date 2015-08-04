class ApplicationController < ActionController::API
  include ActionController::Serialization

  before_filter :authenticate_user_from_token!

  rescue_from(ActionController::ParameterMissing) do |e|
    generate_error_payload('Missing parameters', 400, "Parameter `#{e.param}` is missing.")
  end

  private
    def authenticate_user_from_token!
      nusnet_id = params[:nusnetId]
      access_token = request.headers['Authorization']
      @user = User.where(nusnet_id: nusnet_id, access_token: access_token).first
      if @user.blank?
        return generate_error_payload('Unauthorized', 401, 'YOU SHALL NOT PASS!')
      end
    end

    def generate_api_payload(type, data = {})
      payload = { type: type }
      payload.merge!({ data: data }) if data.present?

      render json: payload, status: :ok
    end

    def generate_error_payload(status, code, message)
      error = {
        status: status,
        code: code,
        response: {
          message: message
        }
      }

      Rails.logger.info do
        "[#{self.class}][#{self.action_name}] Failed. Parameters: #{params}. Error: #{error}"
      end

      render json: error, status: code
    end
end
