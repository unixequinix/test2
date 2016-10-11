TYPES = %w(credit device order money credential access).freeze

class AccessTransaction < ActiveRecord::Base; end
class CreditTransaction < ActiveRecord::Base; end
class CredentialTransaction < ActiveRecord::Base; end
class MoneyTransaction < ActiveRecord::Base; end
class BanTransaction < ActiveRecord::Base; end
class OrderTransaction < ActiveRecord::Base; end
class DeviceTransaction < ActiveRecord::Base; end
class Transaction < ActiveRecord::Base; self.inheritance_column = "not_a_column"; end

class MoveTransactionsIntoSameTable < ActiveRecord::Migration

  def change
    TYPES.each do |type|
      Transactions::Importer.perform_later "#{type}_transaction"
    end
  end
end
