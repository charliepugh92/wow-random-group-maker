class AddSkipFlagToCharacter < ActiveRecord::Migration[5.1]
  def change
    add_column :characters, :do_not_include, :boolean, default: false
  end
end
