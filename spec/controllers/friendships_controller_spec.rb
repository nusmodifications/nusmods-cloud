require 'rails_helper'

RSpec.describe FriendshipsController, type: :controller do
  let(:user) do
    User.new(nusnet_id: 'a0123456', name: 'LIU XINAN')
  end

  describe 'GET #index' do
    context 'when user is not authenticated' do
      it 'returns 401 unauthorized' do
        expected = {
          status: 401,
          details: 'YOU SHALL NOT PASS!'
        }.to_json

        get :index, nusnetId: 'a0123456'
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq(expected)
      end
    end

    context 'when user is authenticated' do
      it 'returns 200 success along with friends, outgoing requests, incoming requests' do
        expected = {
          friendships: {
            friends: [
              {
                nusnetId: 'a1234567',
                name: 'Liu Xinan',
                email: nil,
                gender: nil,
                faculty: nil,
                firstMajor: nil,
                secondMajor: nil,
                matriculationYear: nil
              }
            ],
            outgoingRequests: [
              {
                nusnetId: 'a2345678'
              }
            ],
            incomingRequests: [
              {
                nusnetId: 'a3456789',
                name: 'Tay Yang Shun',
                email: nil,
                gender: nil,
                faculty: nil,
                firstMajor: nil,
                secondMajor: nil,
                matriculationYear: nil
              }
            ]
          }
        }.to_json

        expect_any_instance_of(User).to receive(:friends).at_least(:once)
            .and_return([User.new(nusnet_id: 'a1234567', name: 'Liu Xinan')])
        expect_any_instance_of(User).to receive(:outgoing_requests).at_least(:once)
            .and_return([User.new(nusnet_id: 'a2345678', name: 'Xu Bili')])
        expect_any_instance_of(User).to receive(:incoming_requests).at_least(:once)
            .and_return([User.new(nusnet_id: 'a3456789', name: 'Tay Yang Shun')])

        request.headers['Authorization'] = 'this_is_a_token_if_you_believe'
        expect(User).to receive_message_chain(:where, :first)
            .and_return(user)

        get :index, nusnetId: 'a0123456'

        expect(response).to have_http_status(:success)
        expect(response.body).to eq(expected)
      end
    end
  end
end
