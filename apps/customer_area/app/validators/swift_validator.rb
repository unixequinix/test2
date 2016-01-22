class SwiftValidator < ActiveModel::Validator
  def validate(record)
    return if ISO::SWIFT.new(record.swift).valid?
    record.errors.add :swift, record.errors.generate_message(:swift, :invalid)
  end
end
