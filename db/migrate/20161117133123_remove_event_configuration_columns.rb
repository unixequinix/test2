class Event < ActiveRecord::Base
  include FlagShihTzu
  begin
    has_flags(
      1 => :top_ups,
      2 => :refunds,
      3 => :ticket_assignation,
      4 => :gtag_assignation,
      5 => :agreement_acceptance,
      6 => :authorization,
      7 => :transactions_pdf,
      8 => :devices_api,
      9 => :thirdparty_api,
      column: "features"
    )
    has_flags(
      1 => :phone,
      2 => :address,
      3 => :city,
      4 => :country,
      5 => :postcode,
      6 => :gender,
      7 => :birthdate,
      8 => :agreed_event_condition,
      9 => :receive_communications,
      10 => :receive_communications_two,
      column: "registration_parameters"
    )
  rescue
  end
end

class RemoveEventConfigurationColumns < ActiveRecord::Migration
  def change
    settings = {}

    Event.all.each do |event|
      settings[event.id] = {
        registration_settings: {
          phone: event.phone?,
          address: event.address?,
          city: event.city?,
          country: event.country?,
          postcode: event.postcode?,
          gender: event.gender?,
          birthdate: event.birthdate?,
          agreed_event_condition: event.agreed_event_condition?,
          receive_communications: event.receive_communications?,
          receive_communications_two: event.receive_communications_two?
        },
        ticket_assignation: event.ticket_assignation?,
        gtag_assignation: event.gtag_assignation?
      }
    end

    Event.all.each do |event|
      event.update!(
        ticket_assignation: settings[event.id][:ticket_assignation],
        gtag_assignation: settings[event.id][:gtag_assignation],
        registration_settings: settings[event.id][:registration_settings].as_json
      )
    end

    remove_column :events, :features
    remove_column :events, :locales
    remove_column :events, :registration_parameters
  end
end
