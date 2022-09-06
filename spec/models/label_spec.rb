require 'rails_helper'

RSpec.describe Label, type: :model do
  describe 'ラベルモデルのバリデーションテスト' do
    context 'nameが空のとき' do
      let(:label) { build(:label, name: '') }
      it 'ラベルは無効である' do
        expect(label).not_to be_valid
      end
    end

    context '単一ユーザ内で同じ名前のラベルが作られたとき' do
      let!(:user) { create(:user) }
      let!(:label) { create(:label, name: 'label', user:) }
      it 'ラベルは無効である' do
        another_label = build(:label, user:)
        another_label.name = label.name
        expect(another_label).not_to be_valid
      end
    end

    context '異なるユーザ間で同じ名前のラベルが作られたとき' do
      let!(:user1) { create(:user, email: 'user1@example.com') }
      let!(:user2) { create(:user, email: 'user2@example.com') }
      let!(:label) { create(:label, name: 'label', user: user1) }
      it 'どちらも有効である' do
        another_label = build(:label, name: label.name, user: user2)
        expect(another_label).to be_valid
      end
    end
  end
end
