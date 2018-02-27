class ToggleGtagInconsistencyColumns < ActiveRecord::Migration[5.1]
  def change
    Gtag.find_by_sql("UPDATE gtags SET consistent = NOT consistent")
    Gtag.find_by_sql("UPDATE gtags SET complete = NOT complete")
  end
end
