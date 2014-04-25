class AddIndexes < ActiveRecord::Migration
  def change
    add_index :traceroutes, :submitted
    add_index :traceroutes, :failed
    add_index :traceroutes, :available
  end
end
