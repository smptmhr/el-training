RSpec.describe 'Categories', type: :system do
  describe 'カテゴリの作成' do
    before do
      visit categories_path
    end

    context 'カテゴリ名を入力して作成ボタンを押したとき' do
      it 'カテゴリが作成される' do
        # フォームにカテゴリ名を入力して
        fill_in 'カテゴリ名', with: 'test_category'
        # 作成ボタンを押す
        click_on '作成'

        # 作成成功のメッセージが表示され
        expect(page).to have_content 'カテゴリを作成しました'
        # カテゴリ名が表示されている
        expect(page).to have_content 'test_category'
      end
    end

    context 'カテゴリ名を空のまま作成ボタンを押したとき' do
      it 'カテゴリの作成に失敗する' do
        # フォームにカテゴリ名を入力せずに
        fill_in 'カテゴリ名', with: ''
        # 作成ボタンを押す
        click_on '作成'

        # 作成成功のメッセージが表示され
        expect(page).to have_content 'カテゴリ名を入力してください'
      end
    end

    context '存在するカテゴリ名を入力したとき' do
      let!(:category) { create(:category, name: 'test_category') }
      it '作成に失敗する' do
        # すでに存在するカテゴリ名を入力して
        fill_in 'カテゴリ名', with: category.name
        # 作成ボタンを押す
        click_on '作成'

        # カテゴリ名が重複している、とメッセージが出る
        expect(page).to have_content('カテゴリ名はすでに存在します')
      end
    end
  end

  describe 'カテゴリの編集' do
    let!(:category) { create(:category, name: 'test_category') }

    before do
      visit categories_path
    end

    context 'カテゴリ名を正常に更新したとき' do
      it 'カテゴリ名の更新に成功する' do
        id = category.id
        find(".edit_category_#{id}").click

        # カテゴリ編集ページにいる
        expect(page).to have_content('カテゴリ名の変更')

        # 新しいカテゴリ名を入力
        fill_in 'カテゴリ名', with: 'updated_category'
        # 名前を変更ボタンを押す
        click_on '名前を変更'

        # カテゴリ名が正常に更新されている
        expect(page).to     have_content('タスクを更新しました')
        expect(page).to     have_content('updated_category')
        expect(page).not_to have_content('test_category')
      end
    end
    context '存在するカテゴリ名を使って更新しようとしたとき' do
      let!(:another_category){create(:category,name:'another')}
      it '更新に失敗する' do
        id = anoher_category.id
        find(".edit_category_#{id}").click

        # すでに存在するカテゴリ名を使用
        fill_in 'カテゴリ名', with: category.name
        # 名前を変更ボタンを押す
        click_on '名前を変更'

        # カテゴリ名がの更新に失敗する
        expect(page).to have_content('そのカテゴリ名はすでに存在します')
      end
    end
  end
end
