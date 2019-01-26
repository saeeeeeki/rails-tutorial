class AddUniqueNameToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :unique_name, :string
  end
end
