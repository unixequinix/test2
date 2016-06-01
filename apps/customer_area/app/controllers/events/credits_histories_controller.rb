class Events::CreditsHistoriesController < Events::BaseController
  layout false

  def download
    @pdf_transactions = CreditTransaction.where(status_code: 0, profile: current_customer.profile)
                                         .order("device_created_at asc")
    html = render_to_string(action: :history, layout: false)
    pdf = WickedPdf.new.pdf_from_string(html)
    send_data(pdf, filename: "transaction_history_#{current_customer.email}.pdf",
                   disposition: "attachment")
  end
end
