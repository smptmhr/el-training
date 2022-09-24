require 'rails_helper'
# require 'webmock/rspec'

RSpec.describe 'Categories', type: :system do
  include LoginSupport
  
  describe 'エラーページ' do
    describe '404エラー' do
      context '存在しないURLにアクセスしたとき' do
        it '404エラーページに遷移する' do
          visit '/not_exist_page'
          expect(page).to have_content('404')
        end
      end
    end

    describe '500エラー' do
      let!(:user) { create(:user) }
      context 'HTTPステータス500を受け取ったとき' do
        before do
          allow_any_instance_of(TasksController).to receive(:index).and_throw(Exception)
        end
        it '500エラーページに遷移する' do
          # ログインするとindexアクションが呼ばれる
          login_as(user)
          expect(page).to have_content '500'
        end
      end
    end
  end
end
