class CreateHops < ActiveRecord::Migration
  def change
    create_table :hops do |t|
      t.references :traceroute, index: true
      t.integer :no
      t.string :from, limit: 40
      t.float :rtt

      t.timestamps
    end
  end
end
