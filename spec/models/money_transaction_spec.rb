# == Schema Information
#
# Table name: transactions
#
#  action                      :string
#  activation_counter          :integer
#  counter                     :integer
#  credits                     :float
#  device_db_index             :integer
#  direction                   :integer
#  final_access_value          :string
#  final_balance               :float
#  final_refundable_balance    :float
#  gtag_counter                :integer
#  items_amount                :float
#  message                     :string
#  operator_activation_counter :integer
#  operator_value              :string
#  order_item_counter          :integer
#  payment_gateway             :string
#  payment_method              :string
#  price                       :float
#  priority                    :integer
#  refundable_credits          :float
#  status_code                 :integer
#  status_message              :string
#  ticket_code                 :string
#  transaction_origin          :string
#  type                        :string
#
# Indexes
#
#  index_transactions_on_access_id            (access_id)
#  index_transactions_on_catalog_item_id      (catalog_item_id)
#  index_transactions_on_customer_id          (customer_id)
#  index_transactions_on_device_columns       (event_id,device_uid,device_db_index,device_created_at_fixed,gtag_counter,activation_counter) UNIQUE
#  index_transactions_on_event_id             (event_id)
#  index_transactions_on_gtag_id              (gtag_id)
#  index_transactions_on_operator_station_id  (operator_station_id)
#  index_transactions_on_order_id             (order_id)
#  index_transactions_on_station_id           (station_id)
#  index_transactions_on_ticket_id            (ticket_id)
#  index_transactions_on_type                 (type)
#
# Foreign Keys
#
#  fk_rails_091c1eea0c  (ticket_id => tickets.id)
#  fk_rails_35e85c4b19  (catalog_item_id => catalog_items.id)
#  fk_rails_4855921d15  (event_id => events.id)
#  fk_rails_59d791a33f  (order_id => orders.id)
#  fk_rails_984bd8f159  (customer_id => customers.id)
#  fk_rails_9bf7d8b3a6  (gtag_id => gtags.id)
#  fk_rails_f51c7f5cfc  (station_id => stations.id)
#

require "spec_helper"

RSpec.describe MoneyTransaction, type: :model do
  subject { create(:money_transaction, event: build(:event)) }

  describe ".description" do
    it "formats the price correctly in .description" do
      allow(subject).to receive(:price).and_return(2)
      expect(subject.description.split(" ").last).to eq("2.00")
    end
  end

  describe ".mandatory_fields" do
    %w(catalog_item_id items_amount price payment_method).each do |field|
      it "includes the mandatory field '#{field}'" do
        expect(MoneyTransaction.mandatory_fields).to include(field)
      end
    end
  end
end
