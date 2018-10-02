class AddDefaultFalseToGatesHidden < ActiveRecord::Migration[5.1]
  def change
    change_column_default :access_control_gates, :hidden, from: nil, to: false
  end
end
