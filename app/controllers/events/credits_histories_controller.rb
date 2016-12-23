class Events::CreditsHistoriesController < Events::BaseController
  layout false

  def download
    gtag = current_customer.active_gtag
    @pdf_transactions = gtag ? gtag.transactions.credit.status_ok.order(:gtag_counter) : []
    html = render_to_string(action: :history, layout: false)
    pdf = WickedPdf.new.pdf_from_string(html)
    send_data(pdf, filename: "transaction_history_#{current_customer.email}.pdf", disposition: "attachment")
  end
end
