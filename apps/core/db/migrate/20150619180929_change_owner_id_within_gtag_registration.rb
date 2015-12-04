class ChangeOwnerIdWithinGtagRegistration < ActiveRecord::Migration
  class GtagRegistration < ActiveRecord::Base
  end

  def change
    GtagRegistration.find_each do |registration|
      registration.update(admission_id: registration.customer_id)
    end
  end
end
