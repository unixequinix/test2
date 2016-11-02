class OperatorTransaction < Transaction
  def self.mandatory_fields
    super + %w( operator_value operator_station_id )
  end
end
