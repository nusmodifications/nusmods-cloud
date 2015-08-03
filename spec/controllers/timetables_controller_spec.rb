require 'rails_helper'

RSpec.describe TimetablesController, type: :controller do
  let(:timetable) do
    Timetable.new(semester: '2015-2016/sem1', lessons: 'CS3230[LEC]=2&CS3244[LEC]=1')
  end

  let(:user) do
    User.create!(nusnet_id: 'a0123456', name: 'LIU XINAN')
  end

  let(:sample_output) do
    {
      timetable: {
        semester: '2015-2016/sem1',
        lessons: 'CS3230[LEC]=2&CS3244[LEC]=1'
      }
    }.to_json
  end

  describe 'GET #index' do
    context 'when user is not authenticated' do
      it 'returns 401 unauthorized' do
        expected = {
          status: 401,
          details: 'YOU SHALL NOT PASS!'
        }

        get :index, nusnetId: 'a0123456'
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq(expected.to_json)
      end
    end

    context 'when user is authenticated' do
      it 'returns 200 success along with list of timetables' do
        timetables = [
          Timetable.new(semester: '2015-2016/sem1', lessons: 'CS3230[LEC]=2'),
          Timetable.new(semester: '2015-2016/sem2', lessons: '')
        ]

        expected = {
          timetables: [
            {
              semester: '2015-2016/sem1',
              lessons: 'CS3230[LEC]=2'
            },
            {
              semester: '2015-2016/sem2',
              lessons: ''
            }
          ]
        }.to_json

        request.headers['Authorization'] = 'this_is_a_token_if_you_believe'
        expect(User).to receive_message_chain(:where, :first)
            .and_return(user)
        expect_any_instance_of(User).to receive(:timetables).and_return(timetables)

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
          status: 401,
          details: 'YOU SHALL NOT PASS!'
        }

        post :create, nusnetId: 'a0123456'
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq(expected.to_json)
      end
    end

    context 'when user is authenticated' do
      before do
        request.headers['Authorization'] = 'this_is_a_token_if_you_believe'
        allow(User).to receive_message_chain(:where, :first)
            .and_return(user)
      end

      context 'when one or more of the required params are missing' do
        it 'returns 400 bad request' do
          post :create, nusnetId: 'a0123456'
          expect(response).to have_http_status(:bad_request)

          post :create, nusnetId: 'a0123456', lessons: 'CS3230[LEC]=2&CS3244[LEC]=1'
          expect(response).to have_http_status(:bad_request)
        end
      end

      context 'when timetable for that semester exists for the user' do
        it 'updates the timetable for that semester' do
          expect_any_instance_of(User).to receive_message_chain(:timetables, :find_by_semester).and_return(timetable)

          post :create, nusnetId: 'a0123456', semester: '2015-2016/sem1', lessons: 'CS3230[LEC]=2&CS3244[LEC]=1'

          expect(response).to have_http_status(:success)
          expect(response.body).to eq(sample_output)
        end
      end

      context 'when timetable for that semester does not exist for the user' do
        it 'create a new timetable record under the user for that semester' do
          expect_any_instance_of(User).to receive_message_chain(:timetables, :find_by_semester).and_return(nil)

          post :create, nusnetId: 'a0123456', semester: '2015-2016/sem1', lessons: 'CS3230[LEC]=2&CS3244[LEC]=1'

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
          status: 401,
          details: 'YOU SHALL NOT PASS!'
        }.to_json

        get :show, nusnetId: 'a0123456', semester: '2015-2016/sem1'
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq(expected)
      end
    end

    context 'when user is authenticated' do
      before do
        request.headers['Authorization'] = 'this_is_a_token_if_you_believe'
        allow(User).to receive_message_chain(:where, :first)
            .and_return(user)
      end

      context 'when all required params are passed in' do
        it 'returns 200 success along with the timetable if requested timetable exists' do
          expect_any_instance_of(User).to receive_message_chain(:timetables, :find_by_semester).and_return(timetable)

          get :show, nusnetId: 'a0123456', semester: '2015-2016/sem1'

          expect(response).to have_http_status(:success)
          expect(response.body).to eq(sample_output)
        end

        it 'returns 404 not found if requested timetable does not exists' do
          expect_any_instance_of(User).to receive_message_chain(:timetables, :find_by_semester).and_return(nil)

          expected = {
            status: 404,
            details: 'Timetable of the requested semester does not exist.'
          }.to_json

          get :show, nusnetId: 'a0123456', semester: '2015-2016/sem1'

          expect(response).to have_http_status(:not_found)
          expect(response.body).to eq(expected)
        end
      end
    end
  end
end
