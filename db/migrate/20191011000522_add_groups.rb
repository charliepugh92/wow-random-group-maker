class AddGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :group_runs do |t|
      t.timestamps
    end

    create_table :groups do |t|
      t.references :group_run

      t.integer :tank_id
      t.integer :healer_id
    end

    create_table :group_dps do |t|
      t.references :group

      t.integer :dps_id
    end
  end
end
