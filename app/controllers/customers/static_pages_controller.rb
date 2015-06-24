class Customers::StaticPagesController < Customers::BaseController
  skip_before_action :authenticate_customer!


  def privacy_policy
  end

  def terms_of_use
  end

end