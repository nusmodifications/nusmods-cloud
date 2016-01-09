class IVLE
  include HTTParty
  base_uri 'https://ivle.nus.edu.sg/api/Lapi.svc'

  def initialize(token, api_key = ENV['IVLE_API_KEY'])
    # Using both `AuthToken` and `Token` because IVLE auth params are inconsistent. (╯°□°)╯︵ ┻━┻
    @options = { query: { APIKey: api_key, AuthToken: token, Token: token } }
    begin
      response = self.class.get('/Validate', @options)
      if response.code != 200
        raise 'Invalid API key!'
      elsif response.parsed_response['Success'].blank?
        raise 'Invalid token!'
      end
      @valid = true
    rescue => e
      Rails.logger.info { "[IVLE] Validation failed. Error: #{e}" }
      @valid = false
    end
  end

  ### get_profile | Get the student's profile from IVLE
  # Sample result:
  # {
  #   nusnet_id: 'a0123456',
  #   name: 'LIU XINAN',
  #   email: 'xinan@u.nus.edu',
  #   gender: 'Male',
  #   faculty: 'School of Computing',
  #   first_major: 'Computer Science (Hons)',
  #   second_major: '',
  #   matriculation_year: '2014'
  #   ivle_token: 'blah_blah_blah'
  # }
  def get_profile
    return nil unless @valid
    begin
      response = self.class.get('/Profile_View', @options)
      result = response.parsed_response['Results'][0]
      result = Hash[result.map { |k, v| [k.underscore.intern, v] }]
      result[:nusnet_id] = result.delete(:user_id)
      result.slice(:nusnet_id, :name, :email, :gender, :faculty, :first_major, :second_major, :matriculation_year)
        .merge(ivle_token: @options[:query][:Token])
    rescue
      nil
    end
  end
end
