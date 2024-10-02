class CreateRows < ActiveRecord::Migration[7.2]
  def change
    create_table :rows do |t|
      t.timestamps
    end
  end
end
