class OrderMailer < ApplicationMailer
  def completed_email(order, event)
    config_parameters(order, event)
    mail(to: order.customer.email, subject: I18n.t('email.customer.order.completed.subject'))

  end

  private

  def config_parameters(order, event)
    headers['X-No-Spam'] = 'True'
    @name = order.customer.name + ' ' + order.customer.surname
    @order = order
    @event = event
  end
end
