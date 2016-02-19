class Jobs::Base < ActiveJob::Base
  def self.write(category, atts)
    klass = "#{category}_transaction".classify.constantize
    obj = klass.create!(atts)
    workers = descendants.select { |w| w::TYPES.include? atts[:transaction_type] }
    workers.each { |worker|  worker.perform_later(obj.id) }
  end

  def self.inherited(klass)
    @descendants ||= []
    @descendants << klass
  end

  def self.descendants
    @descendants || []
  end
end
