module Admins
  class EventsController < BaseController
    include EventsHelper
    include AnalyticsHelper

    before_action :set_event, except: %i[index new sample_event create]
    before_action :set_event_series, only: %i[index new edit]
    before_action :set_new_event, only: %i[index new]
    before_action :set_current_tab, only: %i[new edit destroy]

    def index
      @q = policy_scope(Event).ransack(params[:q])
      @events = @q.result.order(state: :asc, start_date: :desc, name: :asc)
      authorize(@events)
      @alerts = Alert.where(event: @events.map(&:id)).unresolved.group(:event_id).count
    end

    def new
      authorize(@event)
    end

    def edit
      @current_tab ||= params[:tab]
      @versions = @current_event.versions.reorder(created_at: :desc)
      render layout: "admin_event"
    end

    def refund_fields
      render layout: "admin_event"
    end

    def show
      @load_analytics_resources = true
      data = cache_method("event_analytics", { group: :hour, credits: @credits }, 3600)
      @activity = { chart_id: "event_activity", data: data }

      render layout: "admin_event"
    end

    def create
      @event = Event.new(permitted_params)
      authorize(@event)

      if @event.save
        @event.event_registrations.create!(user: current_user, role: :promoter)
        @event.initial_setup!
        redirect_to admins_event_path(@event), notice: t("alerts.created")
      else
        flash[:error] = t("alerts.error")
        render :new
      end
    end

    def update
      params[:event] ||= {}
      params[:event][:refund_fields] = [] if params[:event].blank?

      pp = permitted_params
      pp[:start_date] = Time.parse(permitted_params[:start_date]) if permitted_params[:start_date] # rubocop:disable Rails/TimeZone
      pp[:end_date] = Time.parse(permitted_params[:end_date]) if permitted_params[:end_date] # rubocop:disable Rails/TimeZone

      respond_to do |format|
        if @current_event.update(pp.merge(slug: nil))
          format.html { redirect_to [:admins, @current_event], notice: t("alerts.updated") }
          format.json { render json: @current_event }
        else
          @versions = @current_event.versions.reorder(created_at: :desc)
          format.html { render :edit, layout: "admin_event" }
          format.json { render json: @current_event.errors.to_json, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      transactions = @current_event.transactions
      SaleItem.where(credit_transaction_id: transactions).delete_all
      Transaction.where(id: transactions).delete_all
      catalog_items = @current_event.catalog_items.pluck(:id)
      PackCatalogItem.where(catalog_item_id: catalog_items).delete_all
      Transaction.where(catalog_item_id: catalog_items).update_all(catalog_item_id: nil)
      @current_event.device_transactions.delete_all
      @current_event.tickets.delete_all
      @current_event.gtags.delete_all
      @current_event.destroy
      redirect_to admins_events_path(status: params[:status]), notice: t("alerts.destroyed")
    end

    def sample_event
      @event = SampleEvent.run(@current_user)
      @event.event_registrations.create!(user: current_user, role: :promoter)
      authorize(@event)
      redirect_to [:admins, @event], notice: t("alerts.created")
    end

    def launch
      @current_event.update_attribute :state, "launched"
      redirect_to request.referer, notice: t("alerts.updated")
    end

    def close
      @current_event.update! state: "closed", open_devices_api: false, open_portal: false, open_portal_intercom: false, open_api: false
      @current_event.device_registrations.update_all(allowed: true)
      @current_event.ticketing_integrations.update_all(status: "inactive")

      redirect_to [:admins, @current_event], notice: t("alerts.updated")
    end

    def remove_db
      @current_event.update(params[:db] => nil)
      redirect_to admins_event_device_registrations_path(@current_event)
    end

    def remove_logo
      @current_event.logo.destroy
      @current_event.logo.clear
      @current_event.save
      redirect_to request.referer, notice: t("alerts.destroyed")
    end

    def remove_background
      @current_event.background.destroy
      @current_event.background.clear
      @current_event.save
      redirect_to request.referer, notice: t("alerts.destroyed")
    end

    def zoho_report
      secrets = Rails.application.secrets
      credentials = Aws::Credentials.new(secrets.s3_access_key_id, secrets.s3_secret_access_key)
      s3 = Aws::S3::Resource.new(region: 'eu-west-1', credentials: credentials)
      bucket = s3.bucket(Rails.application.secrets.s3_bucket)

      reports_url = "gspot/event/#{@current_event.id}/reports"
      reports_files = bucket.objects(prefix: reports_url).collect(&:key)

      redirect_to(request.referer, notice: "No old reports found") && return unless reports_files.any?

      zip_file = Tempfile.new(["reports_event_id_#{@current_event.id}_", ".zip"])
      Zip::File.open(zip_file.path, Zip::File::CREATE)
      bucket.object(reports_files[0]).get(response_target: zip_file.path)

      send_file(
        zip_file.path,
        filename: "#{@current_event.name}.zip",
        type: "application/zip"
      )
    end

    def activate_online_topups
      @current_event.open_topups = true
      res = @current_event.sync_to_wiredlion
      if res.present? && res['event'].present?
        redirect_to edit_admins_event_path(@current_event, tab: 'portal-panel'), notice: "Online topups activated correctly. Check the WiredLion link below."
      elsif res.blank? || res['errors'].present?
        redirect_to edit_admins_event_path(@current_event, tab: 'portal-panel'), alert: (res.present? ? pretty_print_json(res['errors']) : 'Error synchronizing to Wired Lion. Please try again in some minutes.').to_s
      end
    end

    private

    def set_event_series
      @event_series = []
      @event_series = EventSerie.where(id: @current_user.team.events.pluck(:event_serie_id)) if @current_user.team
    end

    def set_event
      @current_event = Event.friendly.find(params[:id])
      authorize(@current_event)
      @credit_value = @current_event.credit.value
    end

    def set_new_event
      @event = Event.new(start_date: Time.zone.now.beginning_of_day, end_date: (Time.zone.now + 3.days).end_of_day)
    end

    def set_current_tab
      @current_tab = params[:current_tab]
    end

    def use_time_zone
      Time.use_zone(@current_event.timezone) { yield }
    end

    def permitted_params
      params[:event][:voucher_products] = params[:event][:voucher_products]&.split(',')
      params.require(:event).permit(:action,
                                    :state,
                                    :name,
                                    :url,
                                    :start_date,
                                    :end_date,
                                    :support_email,
                                    :customer_compliance,
                                    :style,
                                    :logo,
                                    :background,
                                    :currency,
                                    :official_name,
                                    :official_address,
                                    :address,
                                    :registration_num,
                                    :timezone,
                                    :phone_mandatory,
                                    :address_mandatory,
                                    :gender_mandatory,
                                    :birthdate_mandatory,
                                    :bank_format,
                                    :private_zone_password,
                                    :fast_removal_password,
                                    :emv_topup_enabled,
                                    :emv_pos_enabled,
                                    :transaction_buffer,
                                    :days_to_keep_backup,
                                    :sync_time_event_parameters,
                                    :sync_time_server_date,
                                    :sync_time_basic_download,
                                    :sync_time_tickets,
                                    :sync_time_gtags,
                                    :sync_time_customers,
                                    :format,
                                    :gtag_type,
                                    :gtag_deposit,
                                    :onsite_initial_topup_fee,
                                    :online_initial_topup_fee,
                                    :every_onsite_topup_fee,
                                    :every_online_topup_fee,
                                    :online_refund_fee,
                                    :onsite_refund_fee,
                                    :refund_minimum,
                                    :auto_refunds,
                                    :ultralight_c,
                                    :maximum_gtag_balance,
                                    :maximum_gtag_virtual_balance,
                                    :credit_step,
                                    :gtag_deposit_fee,
                                    :card_return_fee,
                                    :token,
                                    :owner_id,
                                    :gtag_format,
                                    :stations_initialize_gtags,
                                    :stations_apply_orders,
                                    :stations_apply_tickets,
                                    :tips_enabled,
                                    :app_version,
                                    :open_api,
                                    :open_devices_api,
                                    :open_portal,
                                    :open_portal_intercom,
                                    :open_refunds,
                                    :open_topups,
                                    :open_tickets,
                                    :open_gtags,
                                    :refunds_start_date,
                                    :refunds_end_date,
                                    :event_serie_id,
                                    :accounting_code,
                                    :voucher_id,
                                    voucher_products: [],
                                    credit_attributes: %i[id name value],
                                    refund_fields: [])
    end
  end
end
