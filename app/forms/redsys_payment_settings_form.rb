class RedsysPaymentSettingsForm < BaseSettingsForm
  attribute :name, String
  attribute :code, String
  attribute :terminal, String
  attribute :password, String
  attribute :currency, String
  attribute :transaction_type, String
  attribute :pay_methods, String
  attribute :ip, String
  attribute :form, String
  attribute :event_id, Integer

  validates_presence_of :name
  validates_presence_of :code
  validates_presence_of :terminal
  validates_presence_of :password
  validates_presence_of :currency
  validates_presence_of :transaction_type
  validates_presence_of :pay_methods
  validates_presence_of :ip
  validates_presence_of :form
  validates_presence_of :event_id

  private

  def persist!
    persist_parameters(Parameter.where(category: "payment", group: "redsys"))
  end
end
