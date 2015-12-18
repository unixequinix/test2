class GtagAssignmentForm
  include ActiveModel::Model
  include Virtus.model

  attribute :tag_uid, String
  attribute :tag_serial_number, String

  validates_presence_of :tag_uid
  validates_presence_of :tag_serial_number

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  private

  def persist!

  end
end