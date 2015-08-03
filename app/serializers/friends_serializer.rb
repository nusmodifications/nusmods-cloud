class FriendsSerializer < ActiveModel::Serializer
  has_many :friends, serializer: FriendProfileSerializer
  has_many :outgoing_requests, serializer: OutgoingRequestSerializer
  has_many :incoming_requests, serializer: IncomingRequestSerializer
end
