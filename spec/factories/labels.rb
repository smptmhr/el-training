FactoryBot.define do
  factory :label do
    name { 'test_label' }
    user { create(:user) }
  end
end
