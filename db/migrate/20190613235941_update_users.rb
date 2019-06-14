class UpdateUsers < ActiveRecord::Migration[5.2]
  def change
      StubbedUser.update_all(premium: false)
  end
end
