class Events::RegistrationsController < Events::BaseController
  layout "welcome_customer"
  skip_before_filter :authenticate_customer!, only: [:new, :create]
  before_action :check_authorization_flag!

  def new
    @customer_form = NewProfileForm.new
  end

  def create
    atts = new_params.merge(recaptcha: verify_recaptcha(model: @customer_form))

    if new_params["birthdate(1i)"]
      date = Date.new(new_params["birthdate(1i)"].to_i,
                      new_params["birthdate(2i)"].to_i,
                      new_params["birthdate(3i)"].to_i)
      atts[:birthdate] = date
    end

    @customer_form = NewProfileForm.new(atts)
    if @customer_form.save
      flash[:notice] = t("registrations.customer.success")
      redirect_to after_inactive_sign_up_path
    else
      render :new
    end
  end

  def edit
    @edit_profile_form = EditProfileForm.new(current_customer)
  end

  def update # rubocop:disable Metrics/AbcSize
    atts = edit_params

    if edit_params["birthdate(1i)"]
      date = Date.new(edit_params["birthdate(1i)"].to_i,
                      edit_params["birthdate(2i)"].to_i,
                      edit_params["birthdate(3i)"].to_i)
      atts[:birthdate] = date
    end

    @edit_profile_form = EditProfileForm.new(current_customer)
    if @edit_profile_form.validate(atts) && @edit_profile_form.save
      gateway = current_customer&.profile&.payment_gateway_customers
      gateway.find_by_gateway_type("paypal_nvp")&.update(autotopup_amount: params[:autotopup_amount]) if gateway
      redirect_to after_update_path
    else
      render :edit
    end
  end

  private

  def after_update_path
    customer_root_path(current_event)
  end

  def after_inactive_sign_up_path
    event_login_path(current_event, sign_up: true)
  end

  def new_params
    params.require(:new_profile_form).permit(:event_id, :email, :first_name, :last_name, :phone,
                                             :address, :city, :country, :postcode, :gender,
                                             :birthdate, :password, :current_password,
                                             :agreed_on_registration, :agreed_event_condition,
                                             :receive_communications)
  end

  def edit_params
    params.require(:customer).permit(:event_id, :email, :first_name, :last_name, :phone,
                                     :address, :city, :country, :postcode, :gender,
                                     :birthdate, :password, :current_password, :autotopup_amount,
                                     :agreed_on_registration, :agreed_event_condition)
  end
end
