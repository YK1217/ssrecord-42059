class AddTimeToSleepRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :sleep_records, :sleep_time, :integer
  end
end
