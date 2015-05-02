class Admins::CreditsController < Admins::BaseController

  def index
    @credits = Credit.all.includes(:online_product)
  end

  def new
    @credit = Credit.new
    @credit.build_online_product
  end

  def create
    @credit = Credit.new(permitted_params)
    if @credit.save
      flash[:notice] = "created TODO"
      redirect_to admins_credits_url
    else
      flash[:error] = @credit.errors.full_messages.join(". ")
      render :new
    end
  end

  def edit
    @credit = Credit.find(params[:id])
  end

  def update
    @credit = Credit.find(params[:id])
    if @credit.update(permitted_params)
      flash[:notice] = "updated TODO"
      redirect_to admins_credits_url
    else
      flash[:error] = @credit.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    @credit = Credit.find(params[:id])
    @credit.destroy!
    flash[:notice] = "destroyed TODO"
    redirect_to admins_credits_url
  end

  private

  def permitted_params
    params.require(:credit).permit(online_product_attributes: [:name, :description, :price])
  end

end
