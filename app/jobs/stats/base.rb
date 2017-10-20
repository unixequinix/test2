class Stats::Base < ApplicationJob
  queue_as :low

  def self.execute_descendants(transaction_id, action)
    descendants.each { |klass| klass.perform_later(transaction_id) if klass::TRIGGERS.include? action }
  end

  def self.inherited(klass)
    @descendants ||= []
    @descendants << klass
  end

  def self.descendants
    @descendants || []
  end
end
