class UserProfileSerializer < ActiveModel::Serializer
  attributes :nusnet_id, :name, :email, :gender, :faculty, :first_major, :second_major, :matriculation_year, :access_token
end
