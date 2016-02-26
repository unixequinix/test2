class AccessForm
  include ActiveModel::Model
  include Virtus.model

  attribute :name, String
  attribute :description, String
  attribute :step, Integer
  attribute :initial_amount, Integer
  attribute :max_purchasable, Integer
  attribute :min_purchasable, Integer
  attribute :create_credential_type, Boolean, default: false
  attribute :event_id, Integer

  validates_presence_of :name
  validates_presence_of :step
  validates_presence_of :initial_amount
  validates_presence_of :max_purchasable
  validates_presence_of :min_purchasable
  validates_presence_of :event_id

  def save
    @access = Access.new(catalog_item_attributes: { name: name,
                                                   description: description,
                                                   step: step,
                                                   initial_amount: initial_amount,
                                                   max_purchasable: max_purchasable,
                                                   min_purchasable: min_purchasable,
                                                   event_id: event_id
                                                 }
                       )
    if valid?
      persist!
      true
    else
      false
    end
  end

  private

  def persist!
    @access.catalog_item.credential_type = CredentialType.new if create_credential_type
    @access.save
  end
end
