require 'rails_helper'

RSpec.describe RefundService, type: :domain_logic do
  describe 'notify' do
    it 'should initialize the claim and event attributes' do
      claim = build(:claim)
      event = build(:event)
      refund_service = RefundService.new(claim, event)
      expect(refund_service.instance_variable_get(:@claim)).not_to be_nil
      expect(refund_service.instance_variable_get(:@event)).not_to be_nil
    end
  end

  describe 'create' do
    it 'should initialize the claim and event attributes' do
      claim = create(:claim, aasm_state: 'in_progress')
      event = create(:event)
      refund_service = RefundService.new(claim, event)
      refund_service_pending = refund_service.create(amount: '23.00',
                                                     currency: 'EUR',
                                                     message: 'Transaction pending to credit',
                                                     operation_type: 'CREDIT',
                                                     gateway_transaction_number: '113745',
                                                     payment_solution: 'pendingtocredit',
                                                     status: 'PENDING')
      expect(refund_service_pending.class).to eq(ActionMailer::DeliveryJob)

      refund_service_complete = refund_service.create(amount: '23.00',
                                                      currency: 'EUR',
                                                      message: 'Transaction pending to credit',
                                                      operation_type: 'CREDIT',
                                                      gateway_transaction_number: '113745',
                                                      payment_solution: 'pendingtocredit',
                                                      status: 'COMPLETE')
      expect(refund_service_complete).to eq(false)
    end
  end
end
