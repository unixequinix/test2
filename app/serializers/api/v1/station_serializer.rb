module Api
  module V1
    class StationSerializer < ActiveModel::Serializer
      attributes :id, :station_event_id, :type, :name, :hidden, :display_stats, :payment_methods
      attribute :ticket_types_ids, if: :access_station?
      attribute :payment_methods, if: :money_station?

      def attributes(*args)
        hash = super
        method(object.form).call(hash) if object.form
        hash
      end

      def payment_methods
        if object.category.eql?("top_up_refund")
          object.event.emv_topup_enabled ? %w[emv cash] : %w[card cash]
        elsif object.category.in?(%w[bar vendor])
          object.event.emv_pos_enabled ? %w[emv credits] : %w[credits]
        end
      end

      def display_stats
        object.device_stats_enabled
      end

      def ticket_types_ids
        object.ticket_types.pluck(:id)
      end

      def type
        object.category
      end

      def access_station?
        type.in?(%w[ticket_validation check_in])
      end

      def money_station?
        object.category.in?(%w[top_up_refund bar vendor box_office])
      end

      def accreditation(hash)
        hash[:catalog] = object.station_catalog_items.map do |ci|
          { catalog_item_id: ci.catalog_item_id, catalog_item_type: ci.catalog_item.type, price: ci.price.round(2), hidden: ci.hidden? }
        end
      end

      def cs_accreditation(hash)
        hash[:catalog] = object.station_catalog_items.map do |ci|
          { catalog_item_id: ci.catalog_item_id, catalog_item_type: ci.catalog_item.type, price: 0, hidden: ci.hidden? }
        end
      end

      def pos(hash)
        hash[:products] = object.products.map do |sp|
          { product_id: sp.id, price: sp.price.round(2), position: sp.position, hidden: sp.hidden? }
        end
      end

      def topup(hash)
        hash[:top_up_credits] = object.topup_credits.map do |c|
          { amount: c.amount, price: (c.amount * c.credit.value).to_f.round(2), hidden: c.hidden? }
        end
      end

      def access(hash)
        hash[:entitlements] = {
          in: object.access_control_gates.in.map { |g| { id: g.access_id, hidden: g.hidden? } },
          out: object.access_control_gates.out.map { |g| { id: g.access_id, hidden: g.hidden? } }
        }
      end
    end
  end
end
