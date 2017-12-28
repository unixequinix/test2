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
    Pokes::Credit.inspect
    Pokes::Money.inspect
    Pokes::Sale.inspect
    Pokes::Order.inspect
    Pokes::Checkin.inspect
    Pokes::Checkpoint.inspect
    Pokes::Flag.inspect
    Pokes::Message.inspect
    Pokes::Purchase.inspect
    Pokes::Replacement.inspect

    @descendants || []
  end
end
