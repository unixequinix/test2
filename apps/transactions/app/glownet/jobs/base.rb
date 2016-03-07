class Jobs::Base < ActiveJob::Base
  def self.write(atts)
    klass = "#{ atts[:transaction_category] }_transaction".classify.constantize
    obj_atts = extract_attributes(klass, atts)
    obj = klass.find_by(atts.slice(:device_id, :device_db_index)) || klass.create(obj_atts)
    atts[:transaction_id] = obj.id
    workers = descendants.select { |w| w::SUBSCRIPTIONS.include? atts[:transaction_type] }
    workers.each { |worker|  worker.perform_later(atts) }
    obj
  end

  def self.inherited(klass)
    @descendants ||= []
    @descendants << klass unless klass.to_s.include? "Base"
  end

  def self.descendants
    @descendants || []
  end

  def self.extract_attributes(klass, atts)
    column_names = klass.column_names
    atts.dup.keep_if { |k, _| column_names.include? k.to_s }
  end
end
