class BsbValidator < ActiveModel::Validator
  def validate(record)
    bsb = record.bsb.gsub(/[\s-]/, "").strip
    unless bsb.length == 6
      record.errors.add :bsb, record.errors.generate_message(:bsb, :invalid)
    end
  end
end