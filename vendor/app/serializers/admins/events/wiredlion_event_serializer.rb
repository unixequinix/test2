module Admins
  module Events
    class WiredlionEventSerializer < ActiveModel::Serializer
      attributes :name, :glownet_slug, :language, :start, :end, :credit_value, :currency, :environment, :timezone, :owner,
                 :refund_status, :topup_start, :topup_end, :refund_start, :refund_end, :glownet_id, :support_email, :rfid_type,
                 :topup_intercom, :refund_intercom, :credit_name_singular, :credit_name_plural, :logo_url, :background_url,
                 :minimum_balance, :maximum_balance

      def to_json(opts = {})
        "{\"event\":#{super(opts)}}"
      end

      def glownet_id
        object.id
      end

      def glownet_slug
        object.slug
      end

      def language
        'en'
      end

      def start
        object.start_date
      end

      def end
        object.end_date
      end

      def credit_value
        object.credit.value
      end

      def credit_name_singular
        object.credit.name
      end

      def credit_name_plural
        object.credit.name.pluralize
      end

      def environment
        Rails.env.production? ? 'gspot' : 'demo'
      end

      def owner
        object.event_registrations.where(role: 'promoter').first.user.email if object.event_registrations.where(role: 'promoter').present?
      end

      # TODO: refund_status? refunds can be in different status in same event
      def refund_status
        nil
      end

      # TODO: topup_start and topup_end are not in our system
      def topup_start
        nil
      end

      def topup_end
        nil
      end

      def refund_start
        object.refunds_start_date
      end

      def refund_end
        object.refunds_end_date
      end

      def rfid_type
        object.gtag_format
      end

      def topup_intercom
        object.open_portal_intercom
      end

      def refund_intercom
        object.open_portal_intercom
      end

      def logo_url
        object.logo.url if object.logo.present? && URI::DEFAULT_PARSER.make_regexp.match?(object.logo.url)
      end

      def background_url
        object.background.url if object.background.present? && URI::DEFAULT_PARSER.make_regexp.match?(object.background.url)
      end

      def minimum_balance
        0
      end

      def maximum_balance
        object.maximum_gtag_balance
      end
    end
  end
end
