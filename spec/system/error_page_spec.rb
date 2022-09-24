require 'rails_helper'

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

    # rubocop:disable RSpec/AnyInstance
    describe '500エラー' do
      let(:user) { create(:user) }
      before do
        allow_any_instance_of(TasksController).to receive(:index).and_throw(Exception)
      end

      context 'HTTPステータス500を受け取ったとき' do
        it '500エラーページに遷移する' do
          # ログインページするとTasks#indexが呼ばれる
          login_as(user)
          expect(page).to have_content '500'
        end
      end
    end
    # rubocop:enable RSpec/AnyInstance
  end
end
