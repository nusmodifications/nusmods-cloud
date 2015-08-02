class CreateTimetables < ActiveRecord::Migration
  def change
    create_table :timetables do |t|
      t.references :user, index: true, foreign_key: true
      t.string :semester
      t.text :lessons

      t.timestamps null: false
    end
  end
end
