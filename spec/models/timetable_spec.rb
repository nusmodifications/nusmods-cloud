require 'rails_helper'

RSpec.describe Timetable, type: :model do
  subject { Timetable.new }

  describe 'attributes validations' do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to belong_to(:user) }

    it { is_expected.to allow_value('2015-2016/sem1', '2016-2017/sem4').for(:semester) }
    it { is_expected.not_to allow_value('2015-2016/sem5', '2015-2016/sem0', '2015/2016/sem1').for(:semester) }

    VALID_LESSONS1 = 'CS3230[LEC]=2&CS3233R=&CS3244[TUT]=2&CP3200=&FMA1202F[SEM]=1&MS3550='
    VALID_LESSONS2 = ''
    INVALID_LESSONS1 = 'CS3230[LEC]=2&CS3233R=&CS3244[TUT]=2&CP3200=&FMA1202F[SEM]=1&MS3550=3'
    INVALID_LESSONS2 = 'CS3230[LEC]=2&CS3233R=&CS3244[TUT]=2&CP3200=&FMA1202F[SEM]=1&MS3550[]='
    INVALID_LESSONS3 = 'CS3230[LEC]=2&CS3233R=&CS3244[TUT]=2&CP3200=&FMA1202F[SEM]=&MS3550='
    it { is_expected.to allow_value(VALID_LESSONS1, VALID_LESSONS2).for(:lessons) }
    it { is_expected.not_to allow_value(INVALID_LESSONS1, INVALID_LESSONS2, INVALID_LESSONS3).for(:lessons) }
  end
end
