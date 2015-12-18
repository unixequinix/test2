class TicketAssignmentForm
  include ActiveModel::Model
  include Virtus.model

  attribute :number, String

  validates_presence_of :number

  def save
    binding.pry
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