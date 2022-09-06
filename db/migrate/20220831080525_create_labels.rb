class CreateLabels < ActiveRecord::Migration[7.0]
  def change
    create_table :labels do |t|
      t.string :name, index: { unique: true }
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :labels, %i(name user_id), unique: true
  end
end
