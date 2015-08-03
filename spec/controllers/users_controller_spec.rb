require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  describe "GET #auth" do
    context 'when one or more of the required params are missing' do
      it 'returns 400 bad request' do
        get :auth
        expect(response).to have_http_status(:bad_request)

        get :auth, nusnetId: 'A0123456'
        expect(response).to have_http_status(:bad_request)

        get :auth, ivleToken: 'this_is_a_token_if_you_believe'
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when all required params are passed in' do
      let(:sample_profile) do
        {
          nusnet_id: 'a0123456',
          name: 'LIU XINAN',
          email: 'xinan@u.nus.edu',
          gender: 'Male',
          faculty: 'School of Computing',
          first_major: 'Computer Science (Hons)',
          second_major: '',
          matriculation_year: '2014',
          ivle_token: 'this_is_a_token_if_you_believe'
        }
      end

      context 'when ivleToken is not valid or does not match with nusnetId' do
        it 'returns 401 unauthorized' do
          expect(IVLE).to receive_message_chain(:new, :get_profile).and_return(sample_profile)

          get :auth, nusnetId: 'a6543210', ivleToken: 'this_is_a_token_if_you_believe'

          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'when ivleToken is valid and matches with nusnetId' do
        it 'returns 200 success along with user profile' do
          expected = {
            userProfile: {
              nusnetId: 'a0123456',
              name: 'LIU XINAN',
              email: 'xinan@u.nus.edu',
              gender: 'Male',
              faculty: 'School of Computing',
              firstMajor: 'Computer Science (Hons)',
              secondMajor: '',
              matriculationYear: '2014',
              accessToken: '6ppsSGwXujEDTc4V8IoOHRmR9/bWa4yfrs21ZccwT2Q='
            }
          }

          expect(IVLE).to receive_message_chain(:new, :get_profile).and_return(sample_profile)

          get :auth, nusnetId: 'a0123456', ivleToken: 'this_is_a_token_if_you_believe'

          expect(response).to have_http_status(:success)
          expect(response.body).to eq(expected.to_json)
        end
      end
    end
  end

end
