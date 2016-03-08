class Paginator::ApiPaginator
  def self.paginate(arr, page)
    Kaminari.paginate_array(arr).page(page).per(20000)
  end
end
