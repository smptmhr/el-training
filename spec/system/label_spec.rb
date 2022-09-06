require 'rails_helper'

RSpec.describe 'Labels', type: :system do
  include LoginSupport

  let!(:user) { create(:user) }

  describe 'ラベルの作成' do
    before do
      login_as(user)
      click_on 'ラベル一覧'
    end

    context 'ラベル名を入力して作成ボタンを押したとき' do
      it 'ラベルが作成される' do
        # フォームにラベル名を入力して
        fill_in 'label_name', with: 'test_label'
        # 作成ボタンを押す
        click_on '作成'

        # 作成成功のメッセージが表示され
        expect(page).to have_content 'ラベルを作成しました'
        # ラベル名が表示されている
        expect(page).to have_content 'test_label'
      end
    end

    context 'ラベル名を空のまま作成ボタンを押したとき' do
      it 'ラベルの作成に失敗する' do
        # フォームにラベル名を入力せずに
        fill_in 'label_name', with: ''
        # 作成ボタンを押す
        click_on '作成'

        # 作成成功のメッセージが表示され
        expect(page).to have_content 'ラベルの作成に失敗しました'
      end
    end

    context '存在するラベル名を入力したとき' do
      let!(:label) { create(:label, name: 'test_label', user:) }
      it '作成に失敗する' do
        # すでに存在するラベル名を入力して
        fill_in 'label_name', with: label.name
        # 作成ボタンを押す
        click_on '作成'

        # 作成失敗のフラッシュメッセージ
        expect(page).to have_content('ラベルの作成に失敗しました')
      end
    end
  end

  describe 'ラベルの編集' do
    let!(:label) { create(:label, name: 'test_label', user:) }

    before do
      login_as(user)
      click_on 'ラベル一覧'
    end

    context 'ラベル名を正常に更新したとき' do
      it 'ラベル名の更新に成功する' do
        id = label.id
        find(".edit_label_#{id}").click

        # ラベル編集ページにいる
        expect(page).to have_content('ラベル名の変更')

        # 新しいラベル名を入力
        fill_in 'label_name', with: 'updated_label'
        # 名前を変更ボタンを押す
        click_on '名前を変更'

        # ラベル名が正常に更新されている
        expect(page).to     have_content('ラベルを更新しました')
        expect(page).to     have_content('updated_label')
        expect(page).not_to have_content('test_label')
      end
    end

    context '存在するラベル名を使って更新しようとしたとき' do
      let!(:another_label) { create(:label, name: 'another', user:) }
      it '更新に失敗する' do
        # another_labelsの作成をページに反映するために再アクセス
        visit labels_path

        id = another_label.id
        find(".edit_label_#{id}").click

        # すでに存在するラベル名を使用
        fill_in 'label_name', with: label.name
        # 名前を変更ボタンを押す
        click_on '名前を変更'

        # ラベルの更新に失敗する
        expect(page).to have_content('ラベルの更新に失敗しました')
      end
    end
  end

  describe 'ラベルの削除' do
    let!(:label) { create(:label, name: 'test_label', user:) }
    before do
      login_as(user)
      click_on 'ラベル一覧'
    end

    context '削除を押したとき' do
      it 'ラベルが削除される' do
        name = label.name
        expect(page).to have_content(name)
        id = label.id

        # 削除ボタンをクリック
        find(".delete_label_#{id}").click

        # 確認のポップアップが表示される
        expect(page.accept_confirm).to eq '本当に削除しますか?'

        # 削除成功のメッセージが出る
        expect(page).to     have_content('ラベルを削除しました')
        # 削除されたラベル名はページに表示されていない
        expect(page).not_to have_content(name)
      end
    end
  end

  describe 'ラベルによるタスク検索' do
    let!(:category) { create(:category, user:) }
    let!(:label) { create(:label, name: 'label', user:) }
    let!(:task_1) { create(:task, name: 'task_1', category:, user:) }
    let!(:task_2) { create(:task, name: 'task_2', category:, user:) }
    before do
      login_as(user)
      create(:label_table, task: task_1, label:)
      click_on 'タスク一覧'
    end

    context 'ラベル名を選んで検索ボタンを押したとき' do
      it '該当するラベルを持つタスクのみが表示される' do
        select  label.name, from: :label_id
        click_on 'ラベルで検索'

        expect(page).to     have_content(task_1.name)
        expect(page).not_to have_content(task_2.name)
      end
    end
  end
end
