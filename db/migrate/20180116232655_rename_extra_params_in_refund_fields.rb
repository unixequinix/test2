class RenameExtraParamsInRefundFields < ActiveRecord::Migration[5.1]
  def change
    rename_column :refunds, :extra_params, :fields
  end
end
