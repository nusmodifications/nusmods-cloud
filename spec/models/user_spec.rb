require 'rails_helper'

RSpec.describe User, type: :model do
  subject { User.new }

  describe 'attributes validations' do
    it { is_expected.to validate_presence_of(:nusnet_id) }
    it { is_expected.to validate_uniqueness_of(:nusnet_id) }
    it { is_expected.to allow_value('A0123456', 'U0123456', 'u012345').for(:nusnet_id) }
    it { is_expected.not_to allow_value('A0123456M', 'a012345', 'u012345m').for(:nusnet_id) }

    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to allow_value('xinan@nus.edu.sg', 'xinan@u.nus.edu').for(:email) }
    it { is_expected.not_to allow_value('not_a_email', '0123456789').for(:email) }
  end
end
