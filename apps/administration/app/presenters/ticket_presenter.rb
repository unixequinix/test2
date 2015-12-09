class TicketPresenter
  attr_accessor :all_tickets, :tickets_count, :q, :page, :search_query

  def initialize(attributes = {})
    @all_tickets = attributes[:fetcher].tickets
    @search_query = attributes[:search_query]
    @page = attributes[:page]
  end

  def q
    @q = all_tickets.search(search_query)
  end

  def tickets
    q.result(distinct: true)
      .page(page)
      .includes(:ticket_type, :assigned_admission)
  end

  def tickets_count
    all_tickets.count
  end

  def ticket(id)
    all_tickets.includes(admissions: [:customer_event_profile, customer_event_profile: :customer]).find(id)
  end

  def no_tickets_text
    path = "admins/events/shared/"
    search_query.nil? ? path + "no_records" : path + "no_results"
  end


end
