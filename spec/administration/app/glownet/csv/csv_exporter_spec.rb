
require "rails_helper"

RSpec.describe Csv::CsvExporter, type: :domain_logic do
  context "With many Claims in the DB" do
    before :all do
      tag_odd = create(:gtag, tag_uid: "4OBXCHS2FT", tag_serial_number: "MIUE4Z2HNT")
      tag_even = create(:gtag, tag_uid: "5OBXCHS2FT", tag_serial_number: "MOUE4Z2HNT",
                        event: tag_odd.event)
      event = tag_odd.event

      customer_odd = create(:customer,
                            event: event,
                            name: "Diana Mayorga Zamora  ",
                            surname: "Carmona",
                            email: "gustavo.orosco@garibay.es")
      customer_even = create(:customer,
                             event: event,
                             name: "Paco Lopez Jones",
                             surname: "Ojeda",
                             email: "paco.ojeda@eresmas.es")
      profile_odd = create(:customer_event_profile, event: event, customer: customer_odd)
      profile_even = create(:customer_event_profile, event: event, customer: customer_even)

      (1..5).each do |index|
        gtag_id = index.odd? ? tag_odd.id : tag_even.id
        customer_event_profile = index.odd? ? profile_odd : profile_even
        claim = Claim.create(id: index,
                             number: "15102511a6e5" + index.to_s,
                             aasm_state: "completed",
                             completed_at: Date.yesterday,
                             total: 233,
                             created_at: Date.yesterday - 1.day,
                             updated_at: Date.yesterday,
                             gtag_id: gtag_id,
                             service_type: "bank_account",
                             fee: 10.5,
                             minimum: 0,
                             customer_event_profile: customer_event_profile)

        create(:refund, claim: claim)
        params = { data_type: "string", category: "claim", group: "bank_account" }
        p = Parameter.find_by({ name: "iban" }.merge(params))
        create(:claim_parameter, parameter: p, claim: claim, value: "UNCRITM1MN9")
        p = Parameter.find_by({ name: "swift" }.merge(params))
        create(:claim_parameter, parameter: p, claim: claim, value: "IT26U0200802487000005011003")
      end
      @csv_file = Csv::CsvExporter.to_csv(Claim.selected_data(:completed, event))
    end

    describe "the CSV file exported" do
      it "should have the same rows as records in DB +1 (for the headers)" do
        expect(number_of_records_in_csv(@csv_file)).to be(Claim.count)
      end
      it "should be able to export to a file" do
        csv = "id,service_type,name,surname,email,tag_uid,tag_serial_number,amount,iban,swift\n1,bank_account,Diana Mayorga Zamora  ,Carmona,gustavo.orosco@garibay.es,4OBXCHS2FT,MIUE4Z2HNT,9.98,UNCRITM1MN9,IT26U0200802487000005011003\n2,bank_account,Paco Lopez Jones,Ojeda,paco.ojeda@eresmas.es,5OBXCHS2FT,MOUE4Z2HNT,9.98,UNCRITM1MN9,IT26U0200802487000005011003\n3,bank_account,Diana Mayorga Zamora  ,Carmona,gustavo.orosco@garibay.es,4OBXCHS2FT,MIUE4Z2HNT,9.98,UNCRITM1MN9,IT26U0200802487000005011003\n4,bank_account,Paco Lopez Jones,Ojeda,paco.ojeda@eresmas.es,5OBXCHS2FT,MOUE4Z2HNT,9.98,UNCRITM1MN9,IT26U0200802487000005011003\n5,bank_account,Diana Mayorga Zamora  ,Carmona,gustavo.orosco@garibay.es,4OBXCHS2FT,MIUE4Z2HNT,9.98,UNCRITM1MN9,IT26U0200802487000005011003\n"

        expect(@csv_file).to eq(csv)
      end
    end
  end

  context "With many Refunds in the DB" do
    before :each do
      DatabaseCleaner.clean_with :truncation
      claim = create(:claim, id: 100)

      params = {
        created_at: "Tue, 27 Oct 2015 15:34:23 CET +01:00",
        updated_at: "Tue, 27 Oct 2015 15:34:23 CET +01:00",
        claim_id: claim.id,
        amount: 10,
        currency: "eur",
        message: "dummy",
        operation_type: "payment",
        gateway_transaction_number: "epg",
        payment_solution: "dummy",
        status: "completed"
      }

      Refund.create({ id: 100 }.merge(params))
      Refund.create({ id: 200 }.merge(params))
      Refund.create({ id: 300 }.merge(params))

      @csv_file = Csv::CsvExporter.to_csv(Refund.all)
    end

    describe "the CSV file exported" do
      it "should have the attributes included in the headers" do
        csv_headers = get_headers_from_csv_file(@csv_file)
        expect(included_in?(csv_headers, Refund.attribute_names)).to be(true)
      end

      it "should have the same rows as records in DB +1 (for the headers)" do
        expect(number_of_records_in_csv(@csv_file)).to be(Refund.count)
      end
      it "should be able to export to a file" do
        csv = "id,created_at,updated_at,claim_id,amount,currency,message,operation_type," +
              "gateway_transaction_number,payment_solution,status\n"+
              "100,2015-10-27 15:34:23 +0100,2015-10-27 15:34:23 +0100,100,10.0,eur,dummy,payment,"+
              "epg,dummy,completed\n"+
              "200,2015-10-27 15:34:23 +0100,2015-10-27 15:34:23 +0100,100,10.0,eur,dummy,payment,"+
              "epg,dummy,completed\n"+
              "300,2015-10-27 15:34:23 +0100,2015-10-27 15:34:23 +0100,100,10.0,eur,dummy,payment,"+
              "epg,dummy,completed\n"

        expect(@csv_file).to eq(csv)
      end
    end
  end

  private

  def get_headers_from_csv_file(file)
    file.split("\n").first.split(",")
  end

  def included_in?(contained, container)
    (contained - container).empty?
  end

  def number_of_records_in_csv(file)
    file.count("\n") - 1 # remove headers
  end
end
