class ChangeColumnToUsersUniqueName < ActiveRecord::Migration[5.2]
  def change
    change_column_null :users, :unique_name, false
  end
end
