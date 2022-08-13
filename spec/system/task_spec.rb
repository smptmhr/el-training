require 'rails_helper'

def retry_on_stale_element_reference_error(&block)
  first_try = true
  begin
    block.call
  rescue Selenium::WebDriver::Error::StaleElementReferenceError
    warn 'Retry on StaleElementReferenceError'
    if first_try
      first_try = false
      retry
    end
    raise
  end
end

RSpec.describe 'Tasks', type: :system do
  include CreateTestTasksSupport
  describe 'タスクの作成' do
    let(:today) { Time.zone.today }
    let!(:category) { create(:category) }

    before do
      # タスク一覧ページを表示
      visit tasks_path

      # 作成リンクをクリック
      click_on 'タスクを作成'
    end

    context 'description以外の入力フォームを全て埋めたとき' do
      it 'タスクの作成に成功する' do
        # フォームを埋める
        fill_in 'タスク名', with: 'sample task'
        select  category.name, from: 'task[category_id]'
        fill_in '開始日', with: today
        fill_in '必要日数', with: 3
        choose  '未着手'
        choose  '低'

        # 作成実行
        click_button 'Create'

        # 作成成功
        expect(page).to have_content 'タスクを作成しました'

        # indexページにいる
        expect(page).to have_content 'タスク一覧'
      end
    end

    context 'Nameを空のままタスクを作成しようとしたとき' do
      it 'タスクの作成に失敗する' do
        # フォームを埋める
        fill_in 'タスク名', with: ''
        select  category.name, from: 'task[category_id]'
        fill_in '開始日', with: today
        fill_in '必要日数', with: 3
        choose  '未着手'
        choose  '低'

        # 作成実行
        click_button 'Create'

        # 作成失敗
        expect(page).to have_content 'タスクの作成に失敗しました'

        # newページにいる
        expect(page).to have_content 'タスク作成'
      end
    end
  end

  describe 'タスクの更新' do
    let(:task) { create(:task) }

    before do
      # 詳細ページに移動
      visit task_path(task)

      # 編集ページに遷移
      click_link '編集'
    end

    context 'Nameを書き換えて更新したとき' do
      it '更新に成功する' do
        # 新しい名前にして更新
        fill_in      'タスク名', with: 'updated task'
        click_button '変更を保存'

        # 更新成功
        expect(page).to have_content 'タスクを更新しました'

        # 詳細ページにいる
        expect(page).to have_link '一覧に戻る'

        # タスク名が更新されている
        expect(page).to have_content 'updated task'
      end
    end

    context 'Nameを空欄にして更新したとき' do
      it '更新に失敗する' do
        fill_in      'タスク名', with: ''
        click_button '変更を保存'

        expect(page).to have_content 'タスク名を入力してください'
      end
    end
  end

  describe 'タスクの削除' do
    let(:task) { create(:task) }

    before do
      # 詳細ページに移動
      visit task_path(task)
    end

    context '削除ボタンを押したとき' do
      it 'タスクが削除される' do
        # 削除ボタンを押す
        click_button 'タスクを削除'

        # 確認のポップアップが表示される
        expect(page.accept_confirm).to eq '本当に削除しますか?'

        # 削除成功のメッセージが表示される
        expect(page).to have_content 'タスクを削除しました'

        # 一覧ページにいる
        expect(page).to have_content 'タスク一覧'
      end
    end
  end

  describe 'タスクの並び替え' do
    let!(:category) { create(:category) }
    before do
      # タスク一覧ページを表示
      visit tasks_path

      # テストデータ
      create(:task, name: 'a', priority: 2, category:)
      create(:task, name: 'b', priority: 0, category:)
      create(:task, name: 'c', priority: 1, category:)
    end

    context '並び替えたいパラメータを1回だけ選択すると' do
      it 'そのパラメータで昇順に並び替えられる' do
        click_on '重要度'
        expect(current_url).to include('direction=ASC')

        retry_on_stale_element_reference_error do
          tasks = page.all('.task')
          expect(tasks[0]).to have_content '低'
          expect(tasks[1]).to have_content '中'
          expect(tasks[2]).to have_content '高'
        end
      end
    end

    context '同じパラメータを選択すると' do
      it '昇順と降順が入れ替わる' do
        # 最初は昇順に並べ替える
        click_on '重要度'
        expect(current_url).to include('direction=ASC')

        # もう一度押すと降順に並べ替えられる
        click_on '重要度'
        expect(current_url).to include('direction=DESC')

        retry_on_stale_element_reference_error do
          tasks = page.all('.task')
          expect(tasks[0]).to have_content '高'
          expect(tasks[1]).to have_content '中'
          expect(tasks[2]).to have_content '低'
        end
      end
    end
  end

  describe 'タスクを名前で検索する' do
    let(:today) { Time.zone.today }
    let(:test_size) { 55 }
    let(:tasks_num_per_page) { TasksController::TASKS_NUM_PER_PAGE }
    let(:category) { create(:category) }

    before do
      # テスト用データの作成
      test_size.times do |n|
        name           = "test_task_#{n}"
        start_date     = rand(today..(today + 365))
        necessary_days = rand(1..50)
        priority       = rand(0..2)
        progress       = rand(0..2)

        create(:task, name:,
                      category:,
                      start_date:,
                      necessary_days:,
                      priority:,
                      progress:)
      end
      # タスク一覧ページを表示
      visit tasks_path
    end

    context '検索ワードに当てはまるタスクがないとき' do
      it 'メッセージが表示される' do
        fill_in 'search', with: 'no_name'
        select '完全に一致', from: :search_option
        click_on '検索'

        expect(page).to have_content '該当するタスクがありません'
      end
    end

    context '完全に一致オプションを選んだとき' do
      it 'タスク名が全一致するタスクのみ表示される' do
        fill_in 'search', with: 'test_task_15'
        select '完全に一致', from: :search_option
        click_on '検索'

        sleep 1

        # 表示されているタスクは1件で、
        expect(page.all('.task').size).to eq(1)

        # それはタスク15である
        expect(page).to have_content 'test_task_15'
      end
    end

    context '一部を含むオプションを選んだとき' do
      it 'タスク名に検索ワードを含むタスク全てが表示される' do
        fill_in 'search', with: '0'
        select '一部を含む', from: :search_option
        click_on '検索'

        sleep 1

        # 表示されているタスクは6件で、
        expect(page.all('.task').size).to eq(6)

        # それは名前に"0"を含むタスクである
        expect(page).to     have_content 'test_task_0'
        expect(page).to     have_content 'test_task_10'
        expect(page).to     have_content 'test_task_20'
        expect(page).to     have_content 'test_task_30'
        expect(page).to     have_content 'test_task_40'
        expect(page).to     have_content 'test_task_50'
      end
    end
  end

  describe 'ページネーション' do
    let(:tasks_num_per_page) { TasksController::TASKS_NUM_PER_PAGE }
    let(:test_size) { 55 }

    before do
      create_random_tasks_num test_size
      # タスク一覧ページを表示
      visit tasks_path
    end

    context 'indexページを開いたとき' do
      it 'ページネーションが適用されている' do
        # 最初のページに表示されている件数を見る
        expect(page.all('.task').size).to eq(tasks_num_per_page)

        # 最後のページに移動
        click_on 'Last'

        # 最後のページのタスクを正確に取得するにはsleepが必要
        sleep 3

        # 最後のページに表示されている件数を見る
        expect(page.all('.task').size).to eq(test_size % tasks_num_per_page)
      end
    end
  end

  describe 'タスクのフィルタリング' do
    let!(:category) { create(:category) }
    before do
      # タスク一覧ページを表示
      visit tasks_path

      # テストデータ
      create(:task, name: 'a', priority: 0, progress: 0, category:)
      create(:task, name: 'b', priority: 1, progress: 1, category:)
      create(:task, name: 'c', priority: 2, progress: 2, category:)
    end

    context 'フィルタリング条件に該当するタスクが存在するとき' do
      it '該当するタスクのみ表示される' do
        uncheck('filter_priority_中')
        uncheck('filter_progress_完了')

        # このときタスクのフィルタリング条件は
        # (priority == 低 || 高) && (progress == 未着手 || 実行中)
        # task 'a' のみが条件に当てはまる

        click_on('フィルタリング')

        # 表示されているタスクを取得
        tasks = page.all('.task')

        # 表示されているタスク数は1件
        expect(tasks.size).to eq(1)

        # 表示されているタスクは'a'
        expect(tasks[0]).to have_content '低'
      end
    end

    context 'フィルタリングボタンを押したとき' do
      it 'チェックボックスの状態は維持される' do
        # デフォルトでは全てのチェックボックスがチェックされている
        expect(page).to have_checked_field('filter_priority_低')
        expect(page).to have_checked_field('filter_priority_中')
        expect(page).to have_checked_field('filter_priority_高')
        expect(page).to have_checked_field('filter_progress_未着手')
        expect(page).to have_checked_field('filter_progress_実行中')
        expect(page).to have_checked_field('filter_progress_完了')

        # ある項目のチェックを外す
        uncheck('filter_priority_中')
        uncheck('filter_progress_未着手')
        uncheck('filter_progress_完了')

        # 検索ボタンを押す
        click_on('フィルタリング')

        # 選択されていたものは選択されたまま
        expect(page).to have_checked_field('filter_priority_低')
        expect(page).to have_checked_field('filter_priority_高')
        expect(page).to have_checked_field('filter_progress_実行中')

        # チェックが外れていたものはチェックが外れたまま
        expect(page).to have_unchecked_field('filter_priority_中')
        expect(page).to have_unchecked_field('filter_progress_未着手')
        expect(page).to have_unchecked_field('filter_progress_完了')
      end
    end

    context '該当するタスクがないとき' do
      it 'メッセージが表示される' do
        # 検索結果に該当するタスクがないようにチェックを外す
        uncheck('filter_priority_中')
        uncheck('filter_progress_未着手')
        uncheck('filter_progress_完了')

        # 検索ボタンを押す
        click_on('フィルタリング')

        # 選択されていたものは選択されたまま
        expect(page).to have_content('該当するタスクがありません')

        # 表示されているタスクを取得
        tasks = page.all('.task')

        # 表示されているタスク数は0件
        expect(tasks.size).to eq(0)
      end
    end
  end
end
