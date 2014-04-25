class CreateTraceroutes < ActiveRecord::Migration
  def change
    create_table :traceroutes do |t|
      t.string :uuid, limit: 40
      t.string :src, limit: 40
      t.string :dst, limit: 40
      t.string :dst_addr, limit: 40
      t.boolean :submitted
      t.boolean :available
      t.boolean :failed
      t.timestamp :endtime

      t.timestamps
    end
    add_index :traceroutes, :uuid, unique: true
  end
end
