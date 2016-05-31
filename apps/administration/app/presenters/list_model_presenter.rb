class ListModelPresenter
  attr_accessor :all, :q, :page, :search_query, :model_name

  # TODO: Make it lighter. Too many arguments for the initializer
  def initialize(attributes = {})
    @all = attributes[:fetcher]
    @page = attributes[:page]
    @model_name = attributes[:model_name]
    @search_query = attributes[:search_query]
    @include_for_all_items = attributes[:include_for_all_items]
    @context = attributes[:context]
    @can_create_items = attributes[:can_create_items]
  end

  def q
    @q = all.order(:id).search(search_query)
  end

  def all_items
    q.result(distinct: true)
     .page(page)
     .includes(@include_for_all_items)
  end

  def current_items
    @page ||= 1
    items_per_page = @model_name.name.constantize.page.count

    from = first_record(items_per_page)
    to = last_record(items_per_page)

    "#{from}-#{to}"
  end

  delegate :count, to: :all

  def no_items_for_presentation
    path = "admins/events/shared/no_results"
    search_query.nil? ? path + "no_records" : path + "no_results"
  end

  def there_any?
    all_items.present?
  end

  def can_create_items?
    @can_create_items != false &&
      @context.respond_to?("new_admins_event_#{@model_name.singular}_path".to_sym)
  end

  private

  def first_record(items_per_page)
    (items_per_page * (@page.to_i - 1)) + 1
  end

  def last_record(items_per_page)
    last = items_per_page * @page.to_i
    count < last ? count : last
  end
end
