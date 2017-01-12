class UniteEntitlementsEndAccesses < ActiveRecord::Migration[5.0]
  def change
    add_column :catalog_items, :memory_position, :integer
    add_column :catalog_items, :memory_length, :integer
    add_column :catalog_items, :mode, :string

    sql = "UPDATE catalog_items
          SET
            memory_position = entitlements.memory_position,
            memory_length = entitlements.memory_length,
            mode = entitlements.mode
          FROM entitlements
          WHERE entitlements.access_id = catalog_items.id AND catalog_items.type = 'Access'"
    Access.find_by_sql(sql)
    Access.where(memory_position: nil).map {|a| a.set_infinite_values; a.update(mode: Access::PERMANENT, memory_length: 1, memory_position: rand(10))}

    drop_table :entitlements
  end
end

