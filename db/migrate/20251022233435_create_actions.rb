class CreateActions < ActiveRecord::Migration[8.0]
  def change
    create_table :actions do |t|
      t.references :player, null: false, foreign_key: true
      t.string :action_type
      t.integer :target_x
      t.integer :target_y
      t.datetime :completes_at
      t.string :status

      t.timestamps
    end
  end
end
