class User < ActiveRecord::Base
  validates :nusnet_id, presence: true, uniqueness: true, format: { with: /\A(A\d{7}|U\d{6,7})\z/i }
  validates :name, presence: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }

  has_many :timetables, dependent: :destroy
  validates_associated :timetables
end
