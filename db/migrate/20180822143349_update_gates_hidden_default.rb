class UpdateGatesHiddenDefault < ActiveRecord::Migration[5.1]
  def up
    AccessControlGate.where(hidden: nil).find_each do |acg|
      acg.update_column(:hidden, false)
    end
  end

  def down
    AccessControlGate.where(hidden: false).find_each do |acg|
      acg.update_column(:hidden, nil)
    end
  end
end
