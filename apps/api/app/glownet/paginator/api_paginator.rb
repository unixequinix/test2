class Paginator::ApiPaginator
  def self.paginate(arr, page)
    Kaminari.paginate_array(arr).page(page).per(10000)
  end
end
