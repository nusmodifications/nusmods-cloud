ActiveModel::Serializer.setup do |config|
  config.key_format = :lower_camel
end

ActiveModel::Serializer.root = false
