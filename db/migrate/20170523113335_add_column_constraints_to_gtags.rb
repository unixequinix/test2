class AddColumnConstraintsToGtags < ActiveRecord::Migration[5.1]
  def change
    Gtag.where(credits: nil).update_all(credits: 0)
    Gtag.where(refundable_credits: nil).update_all(refundable_credits: 0)
    Gtag.where(final_balance: nil).update_all(final_balance: 0)
    Gtag.where(final_refundable_balance: nil).update_all(final_refundable_balance: 0)

    change_column_null :gtags, :format, false
    change_column_null :gtags, :credits, false
    change_column_null :gtags, :refundable_credits, false
    change_column_null :gtags, :final_balance, false
    change_column_null :gtags, :final_refundable_balance, false

    change_column_default :gtags, :credits, 0
    change_column_default :gtags, :refundable_credits, 0
    change_column_default :gtags, :final_balance, 0
    change_column_default :gtags, :final_refundable_balance, 0
  end
end
