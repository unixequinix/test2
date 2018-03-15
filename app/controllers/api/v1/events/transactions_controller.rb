module Api
  module V1
    module Events
      class TransactionsController < Api::V1::EventsController
        def create
          render(status: :bad_request, json: :bad_request) && return unless params[:_json]
          errors = { atts: [] }

          params[:_json].each.with_index do |atts, index|
            att_errors = validate_params(atts.keys, atts[:type], index)
            errors[:atts] << att_errors && next if att_errors
            Transactions::Base.perform_later(atts.to_unsafe_h)
          end

          params[:_json].delete_if { |elem| validate_params(elem.keys, elem[:type]) }

          errors.delete_if { |_, v| v.compact.empty? }
          render(status: :unprocessable_entity, json: { errors: errors }) && return if errors.any?
          render(status: :created, json: :created)
        end

        private

        def validate_params(keys, category, index = 0)
          return [:category] unless category
          mandatory = category.constantize.mandatory_fields
          missing = (mandatory.map(&:to_sym) - keys.map(&:to_sym)).to_sentence
          "Missing keys for position #{index}: #{missing}" if missing.present?
        end
      end
    end
  end
end
