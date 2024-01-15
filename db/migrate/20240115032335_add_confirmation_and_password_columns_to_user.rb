class AddConfirmationAndPasswordColumnsToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :confirmed_at, :datetime
    add_column :users, :password_digest, :string, null: false
  end
end
