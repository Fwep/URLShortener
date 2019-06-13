class AddDefaultValueToPremiumAttribute < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :premium, :boolean, default: false
  end
end
