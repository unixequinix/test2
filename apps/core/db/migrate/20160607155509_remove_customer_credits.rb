class RemoveCustomerCredits < ActiveRecord::Migration
  class CustomerCredit < ActiveRecord::Base
    belongs_to :profile
  end

  class Profile < ActiveRecord::Base
    has_many :customer_credits
  end

  def change
    add_column :profiles, :credits,                  :decimal, precision: 8, scale: 2, default: 0.00
    add_column :profiles, :refundable_credits,       :decimal, precision: 8, scale: 2, default: 0.00
    add_column :profiles, :final_balance,            :decimal, precision: 8, scale: 2, default: 0.00
    add_column :profiles, :final_refundable_balance, :decimal, precision: 8, scale: 2, default: 0.00

    Profile.includes(:customer_credits).each do |p|
      creds = p.customer_credits
      last = creds.last
      next unless last
      p.credits = creds.map(&:amount).sum
      p.refundable_credits = creds.map(&:refundable_amount).sum
      p.final_balance = last.final_balance
      p.final_refundable_balance = last.final_refundable_balance
      p.save!
    end

    drop_table :customer_credits
  end
end
