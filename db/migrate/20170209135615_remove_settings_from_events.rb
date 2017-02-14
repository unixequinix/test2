class RemoveSettingsFromEvents < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :cards_can_refund, :boolean, default: true
    remove_column :events, :wristbands_can_refund, :boolean, default: true
    remove_column :events, :ticket_assignation, :boolean, default: false
    remove_column :events, :gtag_assignation, :boolean, default: false
  end
end
