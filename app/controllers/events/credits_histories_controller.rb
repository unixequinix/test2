class Events::CreditsHistoriesController < Events::EventsController
  layout false

  def history
    gtag = current_customer.active_gtag
    @pdf_transactions = gtag ? gtag.transactions.credit.status_ok.order(:gtag_counter) : []
    respond_to do |format|
      format.pdf do
        render pdf: "history.pdf", disposition: "inline"
      end
    end
  end
end
