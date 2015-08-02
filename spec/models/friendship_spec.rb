require 'rails_helper'

RSpec.describe Friendship, type: :model do
  subject { Friendship.new }

  describe 'attributes validations' do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to belong_to(:user) }

    it { is_expected.to validate_presence_of(:friend_id) }
    it { is_expected.to belong_to(:friend) }
  end
end
