class OrderMailer < ApplicationMailer
  def completed_email(order, event)
    config_parameters(order)
    attachments.inline['logo'] = File.read("#{Rails.root}/app/assets/images/glow.png")
    attachments.inline['logo-company'] = File.read("#{Rails.root}/#{event.logo.path}") unless event.logo.blank?
    mail(to: order.customer.email, subject: I18n.t('email.customer.order.completed.subject'))

  end

  private

  def config_parameters(order)
    headers['X-No-Spam'] = 'True'
    @name = order.customer.name + ' ' + order.customer.surname
    @order = order
  end
end
