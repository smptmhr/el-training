require 'rails_helper'

RSpec.describe 'Categories', type: :system do
  describe 'エラーページ' do
    describe '404エラー' do
      context '存在しないURLにアクセスしたとき' do
        it '404エラーページに遷移する' do
          visit '/not_exist_page'
          expect(page).to have_content('404')
        end
      end
    end
  end
end
