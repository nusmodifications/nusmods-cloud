class IVLE
  include HTTParty
  base_uri 'ivle.nus.edu.sg/api/Lapi.svc'

  def initialize(api_key, token)
    # Using both `AuthToken` and `Token` because IVLE auth params are inconsistent. (╯°□°)╯︵ ┻━┻
    @options = { query: { APIKey: api_key, AuthToken: token, Token: token } }
    response = self.class.get('/Validate', @options)
    if response.code != 200
      raise 'Invalid API key!'
    elsif response.parsed_response['Success'].blank?
      raise 'Invalid token!'
    end
  end

  def getProfile
    begin
      response = self.class.get('/Profile_View', @options)
      result = response.parsed_response['Results'][0]
      result = Hash[result.map { |k, v| [k.underscore.intern, v] }]
      result[:nusnet_id] = result.delete(:user_id)
      result.merge(ivle_token: @options[:query][:Token])
    rescue
      nil
    end
  end
end
