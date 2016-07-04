class RemoveCustomerCredits < ActiveRecord::Migration
  class CustomerCredit < ActiveRecord::Base
    belongs_to :profile
  end

  class Profile < ActiveRecord::Base
    has_many :customer_credits
  end

  def change
    add_column :profiles, :credits,                  :float, default: 0.00
    add_column :profiles, :refundable_credits,       :float, default: 0.00
    add_column :profiles, :final_balance,            :float, default: 0.00
    add_column :profiles, :final_refundable_balance, :float, default: 0.00

    Profile.includes(:customer_credits).find_in_batches do |profiles|
      profiles.each do |p|
        creds = p.customer_credits
        last = creds.last
        next unless last
        atts[:credits] = creds.map(&:amount).sum
        atts[:refundable_credits] = creds.map(&:refundable_amount).sum
        atts[:final_balance] = last.final_balance
        atts[:final_refundable_balance] = last.final_refundable_balance
        ProfileUpdater.perform_later(atts)
      end
    end

    drop_table :customer_credits
  end
end
