class Api::V1::Events::CreditsController < Api::V1::Events::BaseController
  before_action :set_modified

  def index
    credits = Credit.where(event: current_event)
    credits = credits.where("catalog_items.updated_at > ?", @modified) if @modified
    date = credits.maximum(:updated_at)&.httpdate
    credits = ActiveModelSerializers::Adapter.create(credits.map { |a| Api::V1::CreditSerializer.new(a) }).to_json if credits.present? # rubocop:disable Metrics/LineLength

    render_entity(credits, date)
  end
end
