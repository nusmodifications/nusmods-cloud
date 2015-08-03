require 'rails_helper'

RSpec.describe TimetablesController, type: :controller do
  let(:timetable) do
    Timetable.new(semester: '2015-2016/sem1', lessons: 'CS3230[LEC]=2&CS3244[LEC]=1&CS3244[TUT]=2')
  end

  let(:user) do
    User.create!(nusnet_id: 'a0123456', name: 'LIU XINAN')
  end

  let(:sample_output) do
    {
      timetable: {
        semester: '2015-2016/sem1',
        lessons: 'CS3230[LEC]=2&CS3244[LEC]=1&CS3244[TUT]=2'
      }
    }.to_json
  end

  describe 'POST #create' do
    context 'when user is not authenticated' do
      it 'returns 401 unauthorized' do
        expected = {
          status: 401,
          details: 'YOU SHALL NOT PASS!'
        }

        post :create
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq(expected.to_json)
      end
    end

    context 'when user is authenticated' do
      before do
        request.headers['nusnetId'] = 'a0123456'
        request.headers['accessToken'] = 'this_is_a_token_if_you_believe'
        allow(User).to receive_message_chain(:where, :first)
            .and_return(user)
      end

      context 'when one or more of the required params are missing' do
        it 'returns 400 bad request' do
          post :create
          expect(response).to have_http_status(:bad_request)

          post :create, semester: '2015-2016/sem1'
          expect(response).to have_http_status(:bad_request)

          post :create, lessons: 'CS3230[LEC]=2&CS3244[LEC]=1&CS3244[TUT]=2'
          expect(response).to have_http_status(:bad_request)
        end
      end

      context 'when timetable for that semester exists for the user' do
        it 'updates the timetable for that semester' do
          expect_any_instance_of(User).to receive_message_chain(:timetables, :find_by_semester).and_return(timetable)

          post :create, semester: '2015-2016/sem1', lessons: 'CS3230[LEC]=2&CS3244[LEC]=1&CS3244[TUT]=2'

          expect(response).to have_http_status(:success)
          expect(response.body).to eq(sample_output)
        end
      end

      context 'when timetable for that semester does not exist for the user' do
        it 'create a new timetable record under the user for that semester' do
          expect_any_instance_of(User).to receive_message_chain(:timetables, :find_by_semester).and_return(nil)

          post :create, semester: '2015-2016/sem1', lessons: 'CS3230[LEC]=2&CS3244[LEC]=1&CS3244[TUT]=2'

          expect(response).to have_http_status(:success)
          expect(response.body).to eq(sample_output)
        end
      end
    end
  end
end
