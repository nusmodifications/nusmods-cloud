class ChangeMatriculationYearToStringInUser < ActiveRecord::Migration
  def up
    change_column :users, :matriculation_year, :string
  end

  def down
    change_column :users, :matriculation_year, :integer
  end
end
