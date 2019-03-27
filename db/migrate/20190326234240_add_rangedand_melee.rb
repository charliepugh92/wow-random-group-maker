class AddRangedandMelee < ActiveRecord::Migration[5.1]
  def up
    add_column :characters, :rdps, :boolean
    add_column :characters, :mdps, :boolean

    Character.all.each do |character|
      character.update(rdps: character.dps, mdps: character.dps)
    end

    remove_column :characters, :dps
  end

  def down
    add_column :characters, :dps, :boolean

    Character.all.each do |character|
      character.update(dps: character.mdps || character.rdps)
    end

    remove_column :characters, :rdps
    remove_column :characters, :mdps
  end
end
