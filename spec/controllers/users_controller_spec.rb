require 'rails_helper'

RSpec.describe UsersController, type: :controller do
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

  let(:sample_output) do
    {
      type: 'userProfile',
      data: {
        nusnetId: 'a0123456',
        name: 'LIU XINAN',
        email: 'xinan@u.nus.edu',
        gender: 'Male',
        faculty: 'School of Computing',
        firstMajor: 'Computer Science (Hons)',
        secondMajor: '',
        matriculationYear: '2014',
        accessToken: 'bSR4ncNwDGms74xXe5RF3H7rY6XIb0GT',
        timetables: []
      }
    }.to_json
  end

  describe 'POST #create' do
    context 'when one or more of the required params are missing' do
      it 'returns 400 bad request' do
        post :create
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when all required params are passed in' do
      context 'when ivleToken is not valid' do
        it 'returns 401 unauthorized' do
          expect(IVLE).to receive_message_chain(:new, :get_profile).and_return(nil)

          post :create, ivleToken: 'this_is_a_token_if_you_believe'

          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'when ivleToken is valid' do
        it 'returns 200 success along with user profile' do
          expect(IVLE).to receive_message_chain(:new, :get_profile).and_return(sample_profile)
          expect(SecureRandom).to receive(:base64).with(24).and_return("bSR4ncNwDGms74xXe5RF3H7rY6XIb0GT")

          post :create, ivleToken: 'this_is_a_token_if_you_believe'

          expect(response).to have_http_status(:success)
          expect(response.body).to eq(sample_output)
        end
      end
    end
  end

  describe 'GET #show' do
    context 'when user is not authenticated' do
      it 'returns 401 unauthorized' do
        expected = {
          status: 'Unauthorized',
          code: 401,
          response: {
            message: 'YOU SHALL NOT PASS!'
          }
        }.to_json

        get :show, nusnetId: 'a0123456'

        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq(expected)
      end
    end

    context 'when user is authenticated' do
      it 'returns 200 success along with user profile' do
        expect(User).to receive_message_chain(:where, :first)
            .and_return(User.new(sample_profile.merge(access_token: 'bSR4ncNwDGms74xXe5RF3H7rY6XIb0GT')))

        request.headers['Authorization'] = 'this_is_a_token_if_you_believe'

        get :show, nusnetId: 'a0123456'

        expect(response).to have_http_status(:success)
        expect(response.body).to eq(sample_output)
      end
    end
  end
end
