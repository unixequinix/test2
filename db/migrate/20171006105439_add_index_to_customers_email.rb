class AddIndexToCustomersEmail < ActiveRecord::Migration[5.1]
  def change
    add_index :customers, [:event_id, :email], unique: true
  end
end
