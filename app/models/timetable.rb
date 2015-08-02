class Timetable < ActiveRecord::Base
  validates :user, presence: true
  validates :semester, format: { with: /\A\d{4}-\d{4}\/sem[1234]\z/ }
  validates :lessons, format: { with: /\A([A-Z]+\d{4}[A-Z]*(\[[A-Z]+\])?=\d*\&?)*\z/ }

  belongs_to :user
end
