class AddProbeToTraceroute < ActiveRecord::Migration
  def change
    add_column :traceroutes, :probe, :string, limit: 10
  end
end
