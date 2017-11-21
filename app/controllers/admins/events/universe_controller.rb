class Admins::Events::UniverseController < Admins::Events::BaseController
  protect_from_forgery
  before_action :check_token

  def index
    authorize @current_event, :universe_index?
    cookies.signed[:event_slug] = @current_event.slug
    client = Figaro.env.universe_client_id
    app_uri = Figaro.env.universe_app_uri
    atts = { client_id: client, response_type: :code, redirect_uri: app_uri, response_params: { event_slug: @current_event.slug } }.to_param
    url = "https://www.universe.com/oauth/authorize?#{atts}"

    redirect_to(url) && return if @token.blank?

    import_tickets(false)
    @uv_events = universe_events
    @uv_event = @uv_events.select { |event| event if @current_event.universe_event == event.id }.first
    @uv_attendees = universe_attendees
  end

  def connect
    authorize @current_event, :universe_connect?
    event_id = params[:uv_event_id]
    @current_event.update universe_event: event_id

    redirect_to admins_event_universe_import_tickets_path(@current_event)
  end

  def disconnect
    authorize @current_event, :universe_disconnect?

    @current_event.update! universe_token: nil, universe_event: nil
    redirect_to admins_event_path(@current_event), notice: "Successfully disconnected from Universe"
  end

  def disconnect_event
    authorize @current_event, :universe_disconnect?
    # name = "Universe - #{@current_event.universe_event}"
    @current_event.update! universe_event: nil

    redirect_to admins_event_universe_path(@current_event), notice: "Successfully disconnected from Universe Event"
  end

  def import_tickets(update = true)
    authorize @current_event, :universe_import_tickets?
    uv_event = @current_event.universe_event
    url = URI("https://www.universe.com/api/v2/guestlists?event_id=#{uv_event}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["authorization"] = "Bearer #{@token}"

    response = http.request(request)
    data = JSON.parse(response.body)

    res_object = Hashie::Mash.new data
    tickets_count = res_object.meta['count']
    tickets_api_limit = res_object.meta.limit
    # pagination
    if tickets_count > tickets_api_limit
      (0..(tickets_count / tickets_api_limit) + 1).to_a.each do |_page_number|
        url = URI("https://www.universe.com/api/v2/guestlists?event_id=#{uv_event}&limit=#{tickets_api_limit}&offset=#{tickets_api_limit * _page_number}")
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true

        request = Net::HTTP::Get.new(url)
        request["authorization"] = "Bearer #{@token}"

        response = http.request(request)
        data = JSON.parse(response.body)
        res_object = Hashie::Mash.new data
        res_object.data.guestlist.each { |ticket| UniverseImporter.perform_later(ticket, @current_event.id) }
      end
    else
      res_object.data.guestlist.each { |ticket| UniverseImporter.perform_later(ticket, @current_event.id) }
    end
    redirect_to admins_event_universe_path(@current_event), notice: "All tickets imported" if update
  end

  private

  def check_token
    @token = @current_event.universe_token
    universe_user if @token
    return unless @token.nil?
  end

  def universe_user
    url = URI("https://www.universe.com/api/v2/current_user")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["authorization"] = "Bearer #{@token}"

    response = http.request(request)

    @user_id = JSON.parse(response.body)["current_user"]["id"]
  end

  def universe_events
    url = URI("https://www.universe.com/api/v2/listings?user_id=#{@user_id}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["authorization"] = "Bearer #{@token}"

    response = http.request(request)
    @events = []
    data = JSON.parse(response.body)

    if data["events"].present?
      data["events"].each do |event|
        obj_e = Hashie::Mash.new event
        data["listings"].each do |listing|
          obj_l = Hashie::Mash.new listing
          @events.push obj_l.merge(obj_e) if obj_e.listing_id.eql?(obj_l.id)
        end
      end
    end
    @events
  end

  def universe_attendees
    authorize @current_event, :universe_import_tickets?
    uv_event = @current_event.universe_event
    url = URI("https://www.universe.com/api/v2/guestlists?event_id=#{uv_event}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["authorization"] = "Bearer #{@token}"

    response = http.request(request)
    data = JSON.parse(response.body)
    @uv_attendees = data["meta"]["count"]
  end
end
