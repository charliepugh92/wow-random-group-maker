class AddAllowMultiple < ActiveRecord::Migration[5.1]
  def change
    add_column :characters, :allow_multiple_groups, :boolean, default: false
  end
end
