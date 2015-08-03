class FriendSerializer < ActiveModel::Serializer
  attributes :nusnet_id, :name, :email, :gender, :faculty, :first_major, :second_major, :matriculation_year

  has_many :timetables, serializer: TimetableSerializer
end
