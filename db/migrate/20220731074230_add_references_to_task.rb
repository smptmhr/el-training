class AddReferencesToTask < ActiveRecord::Migration[7.0]
  def change
    add_reference         :tasks, :category,
                          foreign_key: true,
                          null: false,
                          default: Category.find_by(name: "未分類")
  end
end
