module Eventable
  extend ActiveSupport::Concern

  included do
    validate :associations_in_event
  end

  module ClassMethods
    attr_reader :assoc

    private

    def validate_associations(*args)
      args = columns.map(&:name).select { |k| k.to_s.ends_with?("_id") } - ["event_id"] if args.empty?
      @assoc = args.map(&:to_s)
    end
  end

  private

  def associations_in_event
    self.class.assoc.each do |assoc|
      klass = assoc.gsub("_id", "").classify.constantize
      obj = klass.find_by(id: send(assoc))
      errors.add(assoc, "cannot belong to a different event") if obj && obj.event != event
    end
  end
end
