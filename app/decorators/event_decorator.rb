class EventDecorator < Draper::Decorator
  delegate_all

  # Background Types
  BACKGROUND_FIXED = "fixed".freeze
  BACKGROUND_REPEAT = "repeat".freeze
  BACKGROUND_TYPES = [BACKGROUND_FIXED, BACKGROUND_REPEAT].freeze

  def background_fixed?
    object.background_type.eql? BACKGROUND_FIXED
  end

  def background_repeat?
    object.background_type.eql? BACKGROUND_REPEAT
  end

  def self.background_types_selector
    BACKGROUND_TYPES.map { |f| [I18n.t("admin.event.background_types." + f.to_s), f] }
  end
end
