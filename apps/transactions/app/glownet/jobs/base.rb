class Jobs::Base < ActiveJob::Base
  def self.write(atts)
    klass = "#{ atts[:transaction_category] }_transaction".classify.constantize
    obj_atts = extract_attributes(klass, atts)
    search_atts = atts.slice(:event_id, :device_uid, :device_db_index)
    obj = klass.find_by(search_atts) || klass.create(obj_atts)
    atts[:transaction_id] = obj.id
    workers = descendants.select { |worker| worker::SUBSCRIPTIONS.include? atts[:transaction_type] }
    workers.each { |worker|  worker.perform_later(atts) }
    obj
  end

  def self.extract_attributes(klass, atts)
    atts.slice(*klass.column_names.map(&:to_sym))
  end

  def self.inherited(klass)
    @descendants ||= []
    @descendants += klass.to_s.split("::").last.eql?("Base") ? klass.descendants : [klass]
  end

  def self.descendants
    @descendants || []
  end
end
