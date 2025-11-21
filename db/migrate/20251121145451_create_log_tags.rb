class CreateLogTags < ActiveRecord::Migration[7.1]
  def change
    create_table :log_tags do |t|
      t.references :log, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :log_tags, [:log_id, :tag_id], unique: true
  end
end