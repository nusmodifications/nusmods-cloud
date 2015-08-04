require 'rails_helper'

RSpec.describe FriendshipsController, type: :controller do
  let(:user1) do
    User.create(nusnet_id: 'a0123456', name: 'LIU XINAN')
  end

  let(:user2) do
    User.create(nusnet_id: 'a0987654', name: 'Tay Yang Shun')
  end

  describe 'GET #index' do
    context 'when user is not authenticated' do
      it 'returns 401 unauthorized' do
        expected = {
          status: 'Unauthorized',
          code: 401,
          response: {
            message: 'YOU SHALL NOT PASS!'
          }
        }.to_json

        get :index, nusnetId: 'a0123456'
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq(expected)
      end
    end

    context 'when user is authenticated' do
      it 'returns 200 success along with friends, outgoing requests, incoming requests' do
        expected = {
          type: 'friendships',
          data: {
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
            .and_return(user1)

        get :index, nusnetId: 'a0123456'

        expect(response).to have_http_status(:success)
        expect(response.body).to eq(expected)
      end
    end
  end

  describe 'POST #create' do
    context 'when user is not authenticated' do
      it 'returns 401 unauthorized' do
        expected = {
          status: 'Unauthorized',
          code: 401,
          response: {
            message: 'YOU SHALL NOT PASS!'
          }
        }.to_json

        get :index, nusnetId: 'a0123456'
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq(expected)
      end
    end

    context 'when user is authenticated' do
      before do
        request.headers['Authorization'] = 'this_is_a_token_if_you_believe'
        allow(User).to receive_message_chain(:where, :first)
            .and_return(user1)
      end

      context 'but one or more of the required params are missing' do
        it 'returns 400 missing parameters' do
          post :create, nusnetId: 'a0123456'

          expect(response).to have_http_status(:bad_request)
        end
      end

      context 'and requested friend is not in db' do
        it 'returns 404 not found' do
          expect(User).to receive(:find_by_nusnet_id).and_return(nil)
          expected = {
            status: 'Not found',
            code: 404,
            response: {
              message: 'Friend not registered.'
            }
          }.to_json

          post :create, nusnetId: 'a0123456', friendNusnetId: 'a0123456'

          expect(response).to have_http_status(:not_found)
          expect(response.body).to eq(expected)
        end
      end

      context 'and requested friend is already a friend of the user' do
        it 'returns 400 bad request' do
          expect(User).to receive(:find_by_nusnet_id).and_return(user2)
          allow(Friendship).to receive_message_chain(:where, :first)
              .and_return(Friendship.new(user_id: user1.id, friend_id: user2.id, approved: true))

          expected = {
            status: 'Bad request',
            code: 400,
            response: {
              message: 'User a0987654 is already your friend.'
            }
          }.to_json

          post :create, nusnetId: 'a0123456', friendNusnetId: 'a0987654'

          expect(response).to have_http_status(:bad_request)
          expect(response.body).to eq(expected)
        end
      end

      context 'and requested a requested friend' do
        it 'returns 400 bad request' do
          expect(User).to receive(:find_by_nusnet_id).and_return(user2)
          allow(Friendship).to receive_message_chain(:where, :first)
              .and_return(Friendship.new(user_id: user1.id, friend_id: user2.id, approved: false))

          expected = {
            status: 'Bad request',
            code: 400,
            response: {
              message: 'Friend request already sent.'
            }
          }.to_json

          post :create, nusnetId: 'a0123456', friendNusnetId: 'a0987654'

          expect(response).to have_http_status(:bad_request)
          expect(response.body).to eq(expected)
        end
      end

      context 'and requested a incoming friend' do
        it 'returns 200 success and accepts the friend request' do
          expect(User).to receive(:find_by_nusnet_id).and_return(user2)
          allow(Friendship).to receive_message_chain(:where, :first)
              .and_return(Friendship.new(user_id: user2.id, friend_id: user1.id, approved: false))

          expected = {
            type: 'friendProfile',
            data: {
              nusnetId: 'a0987654',
              name: 'Tay Yang Shun',
              email: nil,
              gender: nil,
              faculty: nil,
              firstMajor: nil,
              secondMajor: nil,
              matriculationYear: nil
            }
          }.to_json

          post :create, nusnetId: 'a0123456', friendNusnetId: 'a0987654'

          expect(response).to have_http_status(:success)
          expect(response.body).to eq(expected)
        end
      end

      context 'and requesting a stranger' do
        it 'returns 200 success and creates a outgoing request' do
          expect(User).to receive(:find_by_nusnet_id).and_return(user2)

          expected = {
            type: 'outgoingRequest',
            data: {
              nusnetId: 'a0987654'
            }
          }.to_json

          post :create, nusnetId: 'a0123456', friendNusnetId: 'a0987654'

          expect(response).to have_http_status(:success)
          expect(response.body).to eq(expected)
        end
      end
    end
  end

  describe 'DELETE #delete' do
    context 'when user is not authenticated' do
      it 'returns 401 unauthorized' do
        expected = {
          status: 'Unauthorized',
          code: 401,
          response: {
            message: 'YOU SHALL NOT PASS!'
          }
        }.to_json

        get :index, nusnetId: 'a0123456'
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq(expected)
      end
    end

    context 'when user is authenticated' do
      before do
        request.headers['Authorization'] = 'this_is_a_token_if_you_believe'
        allow(User).to receive_message_chain(:where, :first)
            .and_return(user1)
      end

      context 'and deleting a friend' do
        it 'returns 200 success with type "deleted"' do
          expect(User).to receive(:find_by_nusnet_id).and_return(user2)
          allow(Friendship).to receive_message_chain(:where, :first)
              .and_return(Friendship.new(user_id: user1.id, friend_id: user2.id, approved: true))

          expected = { type: 'deleted' }.to_json

          delete :delete, nusnetId: 'a0123456', friendNusnetId: 'a0987654'

          expect(response).to have_http_status(:success)
          expect(response.body).to eq(expected)
        end
      end

      context 'and canceling a friend request' do
        it 'returns 200 success with type "canceled"' do
          expect(User).to receive(:find_by_nusnet_id).and_return(user2)
          allow(Friendship).to receive_message_chain(:where, :first)
              .and_return(Friendship.new(user_id: user1.id, friend_id: user2.id, approved: false))

          expected = { type: 'canceled' }.to_json

          delete :delete, nusnetId: 'a0123456', friendNusnetId: 'a0987654'

          expect(response).to have_http_status(:success)
          expect(response.body).to eq(expected)
        end
      end

      context 'and rejecting a friend request' do
        it 'returns 200 success with type "rejected"' do
          expect(User).to receive(:find_by_nusnet_id).and_return(user2)
          allow(Friendship).to receive_message_chain(:where, :first)
              .and_return(Friendship.new(user_id: user2.id, friend_id: user1.id, approved: false))

          expected = { type: 'rejected' }.to_json

          delete :delete, nusnetId: 'a0123456', friendNusnetId: 'a0987654'

          expect(response).to have_http_status(:success)
          expect(response.body).to eq(expected)
        end
      end
    end
  end
end
