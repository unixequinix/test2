module Admins
  module Events
    class CreditsController < Admins::Events::BaseController
      before_action :check_amount, only: %i[new create update]
      before_action :destroy_relations, only: %i[destroy]

      def new
        @credit = @current_event.tokens.new
        authorize @credit
      end

      def create
        position = (@current_event.currencies.last.position.to_i + 1)
        @credit = @current_event.tokens.new(permitted_params.merge(spending_order: position, position: position))
        authorize @credit

        if @credit.save
          redirect_to edit_admins_event_path(@current_event, current_tab: 'credits-panel')
        else
          render :new, error: @credit.errors.full_messages.first
        end
      end

      def edit
        @credit = @current_event.currencies.find(params[:id])
        authorize @credit
      end

      def update
        @credit = @current_event.currencies.find(params[:id])
        authorize @credit

        if @credit.update(permitted_params)
          redirect_to edit_admins_event_path(@current_event, current_tab: 'credits-panel')
        else
          render :new
        end
      end

      def destroy
        if @credit.destroy
          redirect_to edit_admins_event_path(@current_event, current_tab: 'credits-panel')
        else
          redirect_to edit_admins_event_path(@current_event, current_tab: 'credits-panel'), error: "Unable to destroy record"
        end
      end

      def sort
        skip_authorization

        params[:order].to_unsafe_h.each_pair do |_key, value|
          next unless value[:id]

          item = CatalogItem.find(value[:id])
          authorize item
          item.update(spending_order: value[:position].to_i)
        end

        head(:ok)
      end

      private

      def destroy_relations
        @credit = @current_event.currencies.find(params[:id])
        authorize @credit

        pack_catalog_items = PackCatalogItem.where(catalog_item: @credit)
        order_items = OrderItem.where(catalog_item: @credit)
        products = Product.where("prices -> '#{@credit.id}' IS NOT NULL")

        if order_items.any?
          orders = @current_event.orders.joins(:order_items).where(order_items: order_items)
          order_items.destroy_all
          orders.where(order_items: { id: nil }).destroy_all
        end

        if pack_catalog_items.any?
          packs = @current_event.packs.where(id: pack_catalog_items.pluck(:pack_id))
          packs.includes(:pack_catalog_items).where(pack_catalog_items: { id: nil }).destroy_all if pack_catalog_items.destroy_all
          packs.destroy_all if packs.any?
        end

        products&.map do |product|
          prices = product.prices.except!(@credit.id.to_s)
          product.destroy && next if prices.empty?
          product.update(prices: prices)
        end
      end

      def check_amount
        @credit_not_available = Event::MAX_CREDITS.eql?(@current_event.credits.count)
        redirect_to edit_admins_event_path(@current_event, current_tab: 'credits-panel') if @credit_not_available
      end

      def permitted_params
        params.require(:credit).permit(:name, :symbol, :max_balance, :color, :type, order: [])
      end
    end
  end
end
