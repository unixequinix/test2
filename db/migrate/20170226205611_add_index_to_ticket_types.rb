class AddIndexToTicketTypes < ActiveRecord::Migration[5.0]
  def change
    TicketType.all.each.with_index { |tt, i| tt.update_column :name, "#{tt.name}-#{i}" } if Rails.env.staging?
    TicketType.all.each.with_index { |tt, i| tt.update_column :name, "#{tt.name}-#{i}" } if Rails.env.hotfix?
    TicketType.all.each.with_index { |tt, i| tt.update_column :name, "#{tt.name}-#{i}" } if Rails.env.integration?
    TicketType.where(event_id: 3).each.with_index { |tt, i| tt.update_column :name, "#{tt.name}-#{i}" }
    TicketType.where(event: Event.all.select{ |e| !e.active? }).each.with_index { |tt, i| tt.update_column :name, "#{tt.name}-#{i}" }
    add_index :ticket_types, [:name, :company_id, :event_id], unique: true
  end
end
