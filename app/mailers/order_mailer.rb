class OrderMailer < ApplicationMailer
  def completed_email(order)
    config_parameters(order)
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/" + "customer-logo.png")
    mail(to: order.customer.email, subject: I18n.t('email.customer.order.completed.subject'))

  end

  private

  def config_parameters(order)
    headers['X-No-Spam'] = 'True'
    @name = order.customer.name + ' ' + order.customer.surname
    @order = order
  end
end
