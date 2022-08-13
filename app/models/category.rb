class Category < ApplicationRecord
  TASK_DEFAULT_BELONG = '未分類'.freeze
  has_many :task, dependent: :restrict_with_error

  # TODO: ユーザモデルが追加されたら、nameのユニーク性のスコープをユーザに変更する
  validates :name, presence: true, uniqueness: true
end
