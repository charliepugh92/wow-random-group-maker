class AddSkillLevels < ActiveRecord::Migration[5.1]
  def change
    add_column :characters, :skill_level, :integer, default: Character.skill_levels[:medium]
  end
end
