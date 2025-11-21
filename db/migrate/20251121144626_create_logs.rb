class CreateLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :logs do |t|
      t.references :user,       null: false, foreign_key: true
      t.references :category,   null: true,  foreign_key: true
      t.string     :title,      null: false
      t.text       :body
      t.text       :code
      t.boolean    :pinned,     null: false, default: false
      t.integer    :copy_count, null: false, default: 0

      t.timestamps
    end
  end
end