class RemoveEventFromCompanies < ActiveRecord::Migration
  def change
    remove_reference :companies, :event
  end
end
