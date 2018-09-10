class AddOperatorToAdmissions < ActiveRecord::Migration[5.1]
  def change
    add_column :tickets, :operator, :boolean, default: false
    add_column :ticket_types, :operator, :boolean, default: false
    add_column :gtags, :operator, :boolean, default: false
  end
end
