class PokeSerializer < ActiveModel::Serializer
  attribute :action, key: "Action"
  attribute :description, key: "Description"
  attribute :location, key: "Location"
  attribute :station_type, key: "Station Type"
  attribute :station_name, key: "Station Name"
  attribute :money, key: "Money"
  attribute :credit_amount, key: "Credits"
  attribute :credit_name, key: "Credit Name"
  attribute :payment_method, key: "Payment Method"
  attribute :event_day, key: "Event Day"
  attribute :customer_uid, key: "Customer UID"
  attribute :customer_id, key: "Customer ID"
  attribute :customer_name, key: "Customer Name"
  attribute :operator_uid, key: "Operator UID"
  attribute :operator_id, key: "Operator ID"
  attribute :operator_name, key: "Operator Name"
  attribute :device_name, key: "Device"
  attribute :activations, key: "Activations"
  attribute :total_devices, key: "Total Devices"
  attribute :product_name, key: "Product Name"
  attribute :sale_item_quantity, key: "Quantity"
  attribute :date_time, key: "Date Time"
  attribute :direction, key: "Direction"
  attribute :access_direction, key: "Access"
  attribute :direction_in, key: "Entries"
  attribute :direction_out, key: "Exits"
  attribute :capacity, key: "Capacity"
  attribute :zone, key: "Zone"
  attribute :ticket_type_name, key: "Ticket Type"
  attribute :catalog_item_name, key: "Catalog Item"
  attribute :total_tickets, key: "Total Tickets"
  attribute :redeemed, key: "Redeemed"
  attribute :sale, key: "Sales"
  attribute :record_credit, key: "Record Credits"
  attribute :source, key: "Source"
  attribute :sorter, key: "sorter"
  attribute :is_alcohol, key: "Alcohol Product"
  attribute :code, key: "Ticket Code"

  def sorter
    object.try(:[], 'sorter')
  end

  def action
    object.try(:[], 'action')&.humanize
  end

  def description
    object.try(:[], 'description')&.humanize
  end

  def location
    object.try(:[], 'location')
  end

  def station_type
    object.try(:[], 'station_type')&.humanize
  end

  def station_name
    object.try(:[], 'station_name')
  end

  def money
    object.try(:[], 'money')
  end

  def credit_amount
    object.try(:[], 'credit_amount')
  end

  def credit_name
    object.try(:[], 'credit_name')
  end

  def payment_method
    return "Virtual" if object.try(:[], 'payment_method') == 'other'
    return "Customer Service" if object.try(:[], 'payment_method') == 'none'
    object.try(:[], 'payment_method')&.humanize
  end

  def customer_id
    object.try(:[], 'customer_id')
  end

  def customer_uid
    object.try(:[], 'customer_uid')
  end

  def customer_name
    object.try(:[], 'customer_name')
  end

  def operator_uid
    object.try(:[], 'operator_uid')
  end

  def operator_name
    object.try(:[], 'operator_name')
  end

  def device_name
    object.try(:[], 'device_name')
  end

  def activations
    object.try(:[], 'activations')
  end

  def total_devices
    object.try(:[], 'total_devices')
  end

  def product_name
    object.try(:[], 'product_name')
  end

  def sale_item_quantity
    object.try(:[], 'sale_item_quantity')
  end

  def event_day
    object.try(:[], 'event_day')
  end

  def date_time
    object.try(:[], 'date_time')
  end

  def direction
    object.try(:[], 'direction')
  end

  def access_direction
    object.try(:[], 'access_direction')
  end

  def zone
    object.try(:[], 'zone')
  end

  def direction_in
    object.try(:[], 'direction_in')
  end

  def direction_out
    object.try(:[], 'direction_out')
  end

  def capacity
    object.try(:[], 'capacity')
  end

  def operator_id
    object.try(:[], 'operator_id')
  end

  def ticket_type_name
    object.try(:[], 'ticket_type_name')
  end

  def total_tickets
    object.try(:[], 'total_tickets')
  end

  def redeemed
    object.try(:[], 'redeemed')
  end

  def catalog_item_name
    object.try(:[], 'catalog_item_name')
  end

  def sale
    object.try(:[], 'sale')
  end

  def record_credit
    object.try(:[], 'record_credit')
  end

  def source
    object.try(:[], 'source')
  end

  def is_alcohol # rubocop:disable Naming/PredicateName
    object.try(:[], 'is_alcohol')
  end

  def code
    object.try(:[], 'code')
  end
end
