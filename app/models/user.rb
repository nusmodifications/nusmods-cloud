class User < ActiveRecord::Base
  validates :nusnet_id, presence: true, uniqueness: true, format: { with: /\A(A\d{7}|U\d{6,7})\z/i }
  validates :name, presence: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }

  has_many :timetables, dependent: :destroy
  validates_associated :timetables

  has_many :friendships, dependent: :destroy
  has_many :passive_friendships, class_name: 'Friendship', foreign_key: 'friend_id', dependent: :destroy

  has_many :active_friends, -> { where(friendships: { approved: true }) }, through: :friendships, source: :friend
  has_many :passive_friends, -> { where(friendships: { approved: true }) }, through: :passive_friendships, source: :user
  has_many :outgoing_requests, -> { where(friendships: { approved: false }) }, through: :friendships, source: :friend
  has_many :incoming_requests, -> { where(friendships: { approved: false }) }, through: :passive_friendships, source: :user

  def friends
    active_friends | passive_friends
  end
end
