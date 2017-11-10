class AddExtraParamsToRefunds < ActiveRecord::Migration[5.1]
  def change
    add_column :refunds, :extra_params, :jsonb, default: {}
  end
end
