class AddMsmIdToTraceroutes < ActiveRecord::Migration
  def change
    add_column :traceroutes, :msm_id, :integer
  end
end
