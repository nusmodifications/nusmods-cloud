class Friendship < ActiveRecord::Base
  validates :user, presence: true
  validates :friend_id, presence: true, uniqueness: { scope: :user }
  validates :approved, inclusion: { in: [true, false] }

  belongs_to :user
  belongs_to :friend, class_name: 'User'
end
