class Transactions::Importer < ActiveJob::Base
  class AccessTransaction < ActiveRecord::Base; end
  class CreditTransaction < ActiveRecord::Base; end
  class CredentialTransaction < ActiveRecord::Base; end
  class MoneyTransaction < ActiveRecord::Base; end
  class BanTransaction < ActiveRecord::Base; end
  class OrderTransaction < ActiveRecord::Base; end
  class DeviceTransaction < ActiveRecord::Base; end
  class Transaction < ActiveRecord::Base; self.inheritance_column = "not_a_column"; end

  def perform(klassname)
    klass = "Transactions::Importer::#{klassname.classify}".constantize
    klass.find_in_batches(batch_size: 20_000) do |ts|
      transactions = ts.map do |t|
        atts = t.attributes
        atts["old_id"] = atts.delete("id")
        atts["type"] = klassname.classify
        Transaction.new(atts)
      end

      Transaction.import transactions, validate: false
    end
  end
end
