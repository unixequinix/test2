class RenameStrictPermanentToPermanentStrict < ActiveRecord::Migration
  def change
    Entitlement.where(mode: "strict_permanent").update_all(mode: "permanent_strict")
  end
end
