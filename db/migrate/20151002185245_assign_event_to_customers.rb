class AssignEventToCustomers < ActiveRecord::Migration
  class Customer < ActiveRecord::Base
    has_many :customer_event_profiles
    belongs_to :event
  end

  class CustomerEventProfile < ActiveRecord::Base
    belongs_to :customer
    belongs_to :event

    validates :customer, :event, presence: true
  end
  def change
    CustomerEventProfile.all.each  do |customer_event_profile|
      customer = customer_event_profile.customer.dup
      customer.event = customer_event_profile.event
      customer.save(validate: false)
      customer_event_profile.customer = customer
      customer_event_profile.save!
    end
    Customer.joins("LEFT JOIN customer_event_profiles
                    ON customers.id = customer_event_profiles.customer_id")
            .where(customer_event_profiles: {id: nil}).each do |customer|
      customer.destroy!
    end
  end
end
