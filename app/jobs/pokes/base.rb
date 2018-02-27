class Pokes::Base < ApplicationJob
  queue_as :low

  def self.execute_descendants(transaction)
    descendants.each { |klass| klass.perform_later(transaction) if klass::TRIGGERS.include? transaction.action }
  end

  def self.inherited(klass)
    @descendants ||= []
    @descendants << klass
  end

  def self.descendants
    load_classes if Rails.env.development?
    @descendants || []
  end

  def load_classes
    Pokes::BalanceUpdater.inspect
    Pokes::Checkin.inspect
    Pokes::Checkpoint.inspect
    Pokes::Credit.inspect
    Pokes::Flag.inspect
    Pokes::Message.inspect
    Pokes::Money.inspect
    Pokes::Operator.inspect
    Pokes::Order.inspect
    Pokes::Purchase.inspect
    Pokes::Replacement.inspect
    Pokes::Sale.inspect
  end
end
