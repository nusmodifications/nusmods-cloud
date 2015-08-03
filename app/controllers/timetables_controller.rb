class TimetablesController < ApplicationController
  before_filter :authenticate_user_from_token!

  def create
    timetable = @user.timetables.find_by_semester(timetable_params[:semester]) || Timetable.new
    timetable.assign_attributes(timetable_params)
    timetable.user = @user
    if timetable.save
      render json: timetable, serializer: TimetableSerializer
    else
      puts timetable.errors.messages
      generate_error_payload(400, 'Failed to save timetable. Please contact support.')
    end
  end

  private
    def timetable_params
      params.require(:semester)
      params.require(:lessons)
      params.permit(:semester, :lessons)
    end
end
