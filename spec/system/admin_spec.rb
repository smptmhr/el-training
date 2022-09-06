require 'rails_helper'

RSpec.describe 'admin page', type: :system do
  let(:admin_user) {
    create(:user, name: 'admin',
                  email: 'admin@example.com',
                  role: :admin)
  }
  before do
    5.times do |user_idx|
      create(:user, name: "user_#{user_idx}",
                    email: "user_#{user_idx}@example.com",
                    password: 'password',
                    password_confirmation: 'password')
    end
  end

  describe 'adminページのアクセス権限' do
    context '管理ユーザでログインしたとき' do
      it 'adminページへのリンクがページに存在する' do
        login_as(admin_user)
        expect(page).to have_content('ユーザ管理')
      end
    end

    context '一般ユーザでログインしたとき' do
      let(:general_user) { User.find_by(name: 'user_0') }

      it 'adminページへのリンクはページに存在しない' do
        login_as(general_user)
        expect(page).not_to have_content('ユーザ管理')
      end
    end
  end

  describe 'adminページトップ' do
    before do
      login_as(admin_user)
      find('.admin_index_link').click
    end

    context '/adminにアクセスしたとき' do
      it 'ユーザ一覧が表示される' do
        5.times do |user_idx|
          expect(page).to have_content "user_#{user_idx}"
        end
      end
    end

    context '削除ボタンを押したとき' do
      it 'ユーザが削除される' do
        delete_user_name = 'user_0'
        id = User.find_by(name: delete_user_name).id

        # 削除するユーザ
        expect(page).to have_content(delete_user_name)

        # ユーザに割り当てられた削除ボタンを押す
        find(".delete_user_#{id}").click

        # 確認のポップアップが表示される
        expect(page.accept_confirm).to eq '本当に削除しますか?'

        # 削除の成功のメッセージが表示される
        expect(page).to have_content('ユーザを削除しました')

        # ユーザは削除されている
        expect(User.find_by(name: delete_user_name)).to be_nil
      end
    end
  end

  describe 'adminページ詳細' do
    before do
      login_as(admin_user)
      find('.admin_index_link').click
    end

    context 'adminページトップでユーザ名を押したとき' do
      it '詳細ページが表示される' do
        click_on 'user_0'
        expect(page).to have_content 'ユーザ情報'
        expect(page).to have_content 'カテゴリ一覧'
        expect(page).to have_content 'タスク一覧'
      end
    end

    context '削除ボタンを押したとき' do
      it 'ユーザが削除される' do
        delete_user_name = 'user_0'

        # 削除するユーザのページへ移動
        click_on delete_user_name

        # ユーザに割り当てられた削除ボタンを押す
        click_on 'ユーザを削除'

        # 確認のポップアップが表示される
        expect(page.accept_confirm).to eq '本当に削除しますか?'

        # 削除の成功のメッセージが表示される
        expect(page).to have_content('ユーザを削除しました')

        # ユーザは削除されている
        expect(User.find_by(name: delete_user_name)).to be_nil
      end
    end

    context 'ユーザ区分を押したとき' do
      it 'ユーザ区分が変更される' do
        user = User.find_by(name: 'user_0') # 一般ユーザ

        # 削除するユーザのページへ移動
        click_on user.name

        # ユーザ区分をクリック
        click_on '一般'

        # 更新成功のメッセージが表示される
        expect(page).to have_content('ユーザ情報を更新しました')

        # 管理ユーザに変更されている
        expect(user.reload.role).to eq(:admin)
      end
    end

    context '管理ユーザが一人のとき' do
      it '管理ユーザ(自分)の区分を変更できない' do
        # 管理ユーザが一人であることを確認
        admin_num = User.where(role: :admin).size
        expect(admin_num).to eq(1)

        click_on admin_user.name

        click_on '管理'

        # エラーメッセージが出力される
        expect(page).to have_content('管理ユーザが0人になってしまうため、その操作はできません')

        # 管理ユーザのままである
        expect(admin_user.reload.role).to eq(:admin)
      end
    end
  end
end
