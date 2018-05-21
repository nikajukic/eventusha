class <%= migration_class_name %> < ActiveRecord::Migration
  def change
		create_table :events do |t|
      t.string :aggregate_id
      t.jsonb :data
      t.string :name

      t.timestamps
    end
  end
end
