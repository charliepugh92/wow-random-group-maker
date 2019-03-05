class CreateCharacters < ActiveRecord::Migration[5.1]
  def change
    create_table :characters do |t|
      t.string :name
      t.boolean :tank
      t.boolean :dps
      t.boolean :healer

      t.timestamps
    end
  end
end
