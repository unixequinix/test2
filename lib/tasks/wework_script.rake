namespace :glownet do
  desc "WeWork Script"
  task wework_script: :environment do
		if Rails.env.production?
			datetime = DateTime.now
			puts "Starting WeWork Script at #{datetime}"
			event = Event.find 439
			virtual_credit = event.virtual_credit
			voucher = event.accesses.find(event.voucher_id)
			ticket_types = event.ticket_types.where(id: [47366, 47365, 47387, 47391, 47394, 47388, 47392, 47393, 47389, 47390, 47383, 47384, 47385, 47386, 47364])
			tickets = event.tickets.where(ticket_type: ticket_types).where.not(customer_id: nil).uniq {|t| t.customer }
			gateway = 'wework_recharge'

			if datetime.day.eql?(19)
				max_virtual = 50.to_f
				max_voucher = 5.to_f
				
				tickets.each do |t|
					order_atts = []
					last_order_not_redeemed = !t.customer.orders.where(gateway: gateway)&.last&.redeemed?
					customer_virtual = t.customer.virtual_credits
					customer_vouchers = t.customer.transactions.status_ok.where(access_id: voucher.id).sum(:direction)
					customer_virtual_amount = (t.customer.active_gtag && !customer_virtual.zero?) ? (max_virtual - customer_virtual) : max_virtual
					customer_vouchers_amount =  (t.customer.active_gtag && !customer_vouchers.zero?) ? (max_voucher - customer_vouchers) : max_voucher
					
					order_atts << [virtual_credit.id, customer_virtual_amount.to_i] unless (customer_virtual == max_virtual && last_order_not_redeemed)
					order_atts << [voucher.id, customer_vouchers_amount.to_i] unless (customer_vouchers == max_voucher && last_order_not_redeemed)

					t.customer.build_order(order_atts).complete!(gateway) unless order_atts.empty?
				end
			else
				max_virtual = 100.to_f
				max_voucher = 10.to_f

				tickets.each do |t|
					order_atts = []
					last_order_not_redeemed = !t.customer.orders.where(gateway: gateway)&.last&.redeemed?
					customer_virtual = t.customer.virtual_credits
					customer_vouchers = t.customer.transactions.status_ok.where(access_id: voucher.id).sum(:direction)
					customer_virtual_amount = (t.customer.active_gtag && !customer_virtual.zero?) ? (max_virtual - customer_virtual) : max_virtual
					customer_vouchers_amount =  (t.customer.active_gtag && !customer_vouchers.zero?) ? (max_voucher - customer_vouchers) : max_voucher
					
					order_atts << [virtual_credit.id, customer_virtual_amount.to_i] unless (customer_virtual == max_virtual && last_order_not_redeemed)
					order_atts << [voucher.id, customer_vouchers_amount.to_i] unless (customer_vouchers == max_voucher && last_order_not_redeemed)
					
					t.customer.build_order(order_atts).complete!(gateway) unless order_atts.empty?
				end
			end
			puts "Ending WeWork Script at #{DateTime.now}"
		elsif Rails.env.staging?
			datetime = DateTime.now
			puts "Starting WeWork Script at #{datetime}"

			event = Event.find 603
			virtual_credit = event.virtual_credit
			voucher = event.accesses.find(event.voucher_id)
			max_virtual = 100.to_f
			max_voucher = 10.to_f
			
			if datetime.day.eql?(16)
				ticket_types = event.ticket_types.where(id: [3299, 3298])
				tickets = event.tickets.where(ticket_type: ticket_types).where.not(customer_id: nil).uniq {|t| t.customer }
				
				tickets.each do |t|
					order_atts = []
					
					last_order_not_redeemed = !t.customer.orders.where(gateway: gateway)&.last&.redeemed?
					customer_virtual = t.customer.virtual_credits
					customer_vouchers = t.customer.transactions.status_ok.where(access_id: voucher.id).sum(:direction)
					customer_virtual_amount = (t.customer.active_gtag && !customer_virtual.zero?) ? (max_virtual - customer_virtual) : max_virtual
					customer_vouchers_amount =  (t.customer.active_gtag && !customer_vouchers.zero?) ? (max_voucher - customer_vouchers) : max_voucher
					
					order_atts << [virtual_credit.id, customer_virtual_amount.to_i] unless (customer_virtual == max_virtual && last_order_not_redeemed)
					order_atts << [voucher.id, customer_vouchers_amount.to_i] unless (customer_vouchers == max_voucher && last_order_not_redeemed)

					t.customer.build_order(order_atts).complete!(gateway) unless order_atts.empty?
				end
			elsif datetime.day.eql?(16)
				ticket_types = event.ticket_types.where(id: [3023])
				tickets = event.tickets.where(redeemed: true, ticket_type: ticket_types).where.not(customer_id: nil).uniq {|t| t.customer }
				
				tickets.each do |t|
					order_atts = []
					max_virtual = 50.to_f
					max_voucher = 5.to_f

					last_order_not_redeemed = !t.customer.orders.where(gateway: gateway)&.last&.redeemed?
					customer_virtual = t.customer.virtual_credits
					customer_vouchers = t.customer.transactions.status_ok.where(access_id: voucher.id).sum(:direction)
					customer_virtual_amount = (t.customer.active_gtag && !customer_virtual.zero?) ? (max_virtual - customer_virtual) : max_virtual
					customer_vouchers_amount =  (t.customer.active_gtag && !customer_vouchers.zero?) ? (max_voucher - customer_vouchers) : max_voucher
					
					order_atts << [virtual_credit.id, customer_virtual_amount.to_i] unless (customer_virtual == max_virtual && last_order_not_redeemed)
					order_atts << [virtual_credit.id, customer_vouchers_amount.to_i] unless (customer_vouchers == max_voucher && last_order_not_redeemed)
					
					t.customer.build_order(order_atts).complete!(gateway) unless order_atts.empty?
				end
			end
			puts "Ending WeWork Script at #{DateTime.now}"
		end
	end
end
