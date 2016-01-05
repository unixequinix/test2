class ListModelPresenter
  attr_accessor :all, :q, :page, :search_query, :model_name

  # TODO - Make it lighter. Too many arguments for the initializer
  def initialize(attributes = {})
    @all = attributes[:fetcher]
    @page = attributes[:page]
    @model_name = attributes[:model_name]
    @search_query = attributes[:search_query]
    @include_for_all_items = attributes[:include_for_all_items]
    @context = attributes[:context]
  end

  def q
    @q = all.order(:id).search(search_query)
  end

  def get_all_items
    q.result(distinct: true)
      .page(page)
      .includes(@include_for_all_items)
  end

  def current_items
    @page ||= 1
    items_per_page = @model_name.name.constantize.page.count

    from = set_first_record(items_per_page)
    to = set_last_record(items_per_page)

    "#{from}-#{to}"
  end

  def count
    all.count
  end

  def no_items_for_presentation
    path = "admins/events/shared/"
    search_query.nil? ? path + "no_records" : path + "no_results"
  end

  def is_there_any?
    get_all_items.present?
  end

  def can_create_items?
    @context.respond_to?("new_admins_event_#{@model_name.singular}_path".to_sym)
  end

  private

  def set_first_record(items_per_page)
    (items_per_page * (@page.to_i - 1)) + 1
  end

  def set_last_record(items_per_page)
    last = items_per_page * @page.to_i
    count < last ? count : last
  end
end
