class Timetable < ActiveRecord::Base
  validates :user, presence: true
  validates :semester, uniqueness: { scope: :user }
  validate :semester_must_be_valid
  validates :lessons, format: { with: /\A([A-Z]+\d{4}[A-Z]*(\[[A-Z]+\])?=\d*\&?)*\z/ }, allow_blank: true

  belongs_to :user

  def semester_must_be_valid
    unless semester =~ /\A20(\d{2})-20(\d{2})\/sem[1234]\z/ && $2.to_i - $1.to_i == 1
      errors.add(:semester, 'is not valid')
    end
  end
end
