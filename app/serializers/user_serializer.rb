class UserSerializer < ActiveModel::Serializer
  attributes :nusnet_id, :name, :email, :gender, :faculty, :first_major, :second_major, :matriculation_year, :access_token

  has_many :active_friends, root: :friends, serializer: FriendSerializer
  has_many :passive_friends, root: :friends, serializer: FriendSerializer
  has_many :outgoing_requests, serializer: OutgoingRequestSerializer
  has_many :incoming_requests, serializer: IncomingRequestSerializer

  has_many :timetables, serializer: TimetableSerializer
end
