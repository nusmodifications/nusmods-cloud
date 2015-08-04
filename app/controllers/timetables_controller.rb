class TimetablesController < ApplicationController
  def index
    timetables = ActiveModel::ArraySerializer.new(@user.timetables, each_serializer: TimetableSerializer)
    generate_api_payload('timetables', timetables)
  end

  def create
    timetable = @user.timetables.find_by_semester(timetable_params[:semester]) || Timetable.new
    timetable.semester = timetable_params[:semester]
    timetable.lessons = timetable_params[:lessons] || ''
    timetable.user = @user
    if timetable.save
      generate_api_payload('timetable', TimetableSerializer.new(timetable))
    else
      puts timetable.errors.messages
      generate_error_payload('Bad request', 400, 'Failed to save timetable. Please contact support.')
    end
  end

  def show
    timetable = @user.timetables.find_by_semester(params[:semester])
    if timetable.present?
      generate_api_payload('timetable', TimetableSerializer.new(timetable))
    else
      generate_error_payload('Not found', 404, 'Timetable of the requested semester does not exist.')
    end
  end

  private
    def timetable_params
      params.require(:semester)
      params.permit(:semester, :lessons)
    end
end
