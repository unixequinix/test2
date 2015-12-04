class RenameAgreedEventConditionMessageToAgreedEventCondition < ActiveRecord::Migration
  def change
    rename_column :customers, :agreed_event_condition_message, :agreed_event_condition
    change_column_default :customers, :agreed_event_condition, false
  end
end