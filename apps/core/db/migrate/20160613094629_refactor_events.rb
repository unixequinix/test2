class RefactorEvents < ActiveRecord::Migration
  def change
    Event.all.each do |event|
      features = event.features
      features += 4 if event.ticket_assignation?
      features += 8 if event.gtag_assignation?
      features += 16 if event.agreement_acceptance?

      event.update!(features: features)
    end

    remove_column :events, :ticket_assignation
    remove_column :events, :gtag_assignation
    remove_column :events, :agreement_acceptance
  end
end
