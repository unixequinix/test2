require "rails_helper"

RSpec.describe CustomerCreditOrderCreator, type: :domain_logic do
  context "An order with some order items." do
    describe "should be able to create a customer credit for every order item possibility:" do
      before :each do
        CustomerCredit.destroy_all
      end

      it "items without credits" do
        order = build(:order)
        access_item = create(:catalog_item, :with_access)
        order.order_items << build(:order_item,
                                   order: order,
                                   catalog_item: access_item,
                                   amount: 2,
                                   total: 2)
        order.save

        coc = CustomerCreditOrderCreator.new
        coc.save(order)

        expect(CustomerCredit.count).to be(0)
      end

      it "one single credit" do
        order = build(:order)
        credit = create(:credit, value: 1, currency: "EUR", standard: false)
        order.order_items << build(:order_item,
                                   order: order,
                                   catalog_item: credit.catalog_item,
                                   amount: 2,
                                   total: 2)
        order.save

        coc = CustomerCreditOrderCreator.new
        coc.save(order)

        expect(CustomerCredit.count).to be(1)

        customer_credit = CustomerCredit.first
        expect(customer_credit.amount).to eq(2.0)
        expect(customer_credit.refundable_amount).to eq(2.0)
        expect(customer_credit.final_balance).to eq(2.0)
        expect(customer_credit.final_refundable_balance).to eq(2.0)
        expect(customer_credit.credit_value).to eq(1.0)
        expect(customer_credit.payment_method).to eq("none")
      end

      it "multiple single credits" do
        order = build(:order)
        credit = create(:credit, value: 1, currency: "EUR", standard: false)
        order.order_items << build(:order_item,
                                   order: order,
                                   catalog_item: credit.catalog_item,
                                   amount: 2,
                                   total: 2)

        credit = create(:credit, value: 2, currency: "EUR", standard: false)
        order.order_items << build(:order_item,
                                   order: order,
                                   catalog_item: credit.catalog_item,
                                   amount: 3,
                                   total: 6)
        order.save

        coc = CustomerCreditOrderCreator.new
        coc.save(order)

        expect(CustomerCredit.count).to eq(2)

        customer_credit = CustomerCredit.first
        expect(customer_credit.amount).to eq(2.0)
        expect(customer_credit.refundable_amount).to eq(2.0)
        expect(customer_credit.final_balance).to eq(2.0)
        expect(customer_credit.final_refundable_balance).to eq(2.0)
        expect(customer_credit.credit_value).to eq(1.0)
        expect(customer_credit.payment_method).to eq("none")

        customer_credit = CustomerCredit.second
        expect(customer_credit.amount).to eq(3.0)
        expect(customer_credit.refundable_amount).to eq(3.0)
        expect(customer_credit.final_balance).to eq(5.0)
        expect(customer_credit.final_refundable_balance).to eq(5.0)
        expect(customer_credit.credit_value).to eq(2.0)
        expect(customer_credit.payment_method).to eq("none")
      end

      it "a pack without credits" do
        order = build(:order)
        access_item_a = create(:catalog_item, :with_access)
        access_item_b = create(:catalog_item, :with_access, event: access_item_a.event)
        catalog_item_with_pack = create(:catalog_item, :with_pack)
        create(:pack_catalog_item,
               pack: catalog_item_with_pack.catalogable,
               catalog_item: access_item_a,
               amount: 4)
        create(:pack_catalog_item,
               pack: catalog_item_with_pack.catalogable,
               catalog_item: access_item_b,
               amount: 5)

        order.order_items << build(:order_item,
                                   order: order,
                                   catalog_item: catalog_item_with_pack,
                                   amount: 2,
                                   total: 2)
        order.save

        coc = CustomerCreditOrderCreator.new
        coc.save(order)

        expect(CustomerCredit.count).to be(0)
      end

      it "a pack with a single credit inside and other stuff" do
        order = build(:order)
        access_item = create(:catalog_item, :with_access)
        credit = create(:credit, value: 2, currency: "EUR", standard: false)
        catalog_item_with_pack = create(:catalog_item, :with_pack)
        create(:pack_catalog_item,
               pack: catalog_item_with_pack.catalogable,
               catalog_item: access_item,
               amount: 4)
        create(:pack_catalog_item,
               pack: catalog_item_with_pack.catalogable,
               catalog_item: credit.catalog_item,
               amount: 5)
        order.order_items << build(:order_item,
                                   order: order,
                                   catalog_item: catalog_item_with_pack,
                                   amount: 2,
                                   total: 15)
        order.order_items.first.catalog_item.catalogable.catalog_items_included(true)
        order.save

        coc = CustomerCreditOrderCreator.new
        coc.save(order)
        expect(CustomerCredit.count).to eq(1)
        customer_credit = CustomerCredit.first
        expect(customer_credit.amount).to eq(10.0)
        expect(customer_credit.refundable_amount).to eq(0)
        expect(customer_credit.final_balance).to eq(10.0)
        expect(customer_credit.final_refundable_balance).to eq(0)
        expect(customer_credit.credit_value).to eq(2.0)
        expect(customer_credit.payment_method).to eq("none")
      end

      it "a pack with a single credit" do
        order = build(:order)
        credit = create(:credit, value: 2, currency: "EUR", standard: false)
        catalog_item_with_pack = create(:catalog_item, :with_pack)
        create(:pack_catalog_item,
               pack: catalog_item_with_pack.catalogable,
               catalog_item: credit.catalog_item,
               amount: 5)

        order.order_items << build(:order_item,
                                   order: order,
                                   catalog_item: catalog_item_with_pack,
                                   amount: 4,
                                   total: 8)
        order.order_items.first.catalog_item.catalogable.catalog_items_included(true)
        order.save

        coc = CustomerCreditOrderCreator.new
        coc.save(order)

        expect(CustomerCredit.count).to eq(1)

        customer_credit = CustomerCredit.first
        expect(customer_credit.amount).to eq(20.0)
        expect(customer_credit.refundable_amount).to eq(4.0)
        expect(customer_credit.final_balance).to eq(20.0)
        expect(customer_credit.final_refundable_balance).to eq(4.0)
        expect(customer_credit.credit_value).to eq(2.0)
        expect(customer_credit.payment_method).to eq("none")
      end

      it "a single credit, more stuff and a pack with a single credit inside" do
        order = build(:order)
        credit_a = create(:credit, value: 2, currency: "EUR", standard: false)
        credit_b = create(:credit, value: 3, currency: "EUR", standard: false)
        access_item = create(:catalog_item, :with_access)
        catalog_item_with_pack = create(:catalog_item, :with_pack)
        create(:pack_catalog_item,
               pack: catalog_item_with_pack.catalogable,
               catalog_item: credit_a.catalog_item,
               amount: 5)

        order.order_items << build(:order_item,
                                   order: order,
                                   catalog_item: catalog_item_with_pack,
                                   amount: 3,
                                   total: 24)

        order.order_items << build(:order_item,
                                   order: order,
                                   catalog_item: access_item,
                                   amount: 2,
                                   total: 4)

        order.order_items << build(:order_item,
                                   order: order,
                                   catalog_item: credit_b.catalog_item,
                                   amount: 5,
                                   total: 15)
        order.order_items.first.catalog_item.catalogable.catalog_items_included(true)
        order.save

        coc = CustomerCreditOrderCreator.new
        coc.save(order)
        expect(CustomerCredit.count).to eq(2)

        customer_credit = CustomerCredit.order(created_at: :desc).first
        expect(customer_credit.amount).to eq(5.0)
        expect(customer_credit.refundable_amount).to eq(5.0)
        expect(customer_credit.final_balance).to eq(20.0)
        expect(customer_credit.final_refundable_balance).to eq(17.0)
        expect(customer_credit.credit_value).to eq(3.0)
        expect(customer_credit.payment_method).to eq("none")
      end

      it "a single credit, more stuff and a pack with a single credit inside" do
        order = build(:order)
        credit_a = create(:credit, value: 2, currency: "EUR", standard: false)
        credit_b = create(:credit, value: 3, currency: "EUR", standard: false)
        access_item = create(:catalog_item, :with_access)
        catalog_item_with_pack = create(:catalog_item, :with_pack)
        create(:pack_catalog_item,
               pack: catalog_item_with_pack.catalogable,
               catalog_item: credit_a.catalog_item,
               amount: 5)

        order.order_items << build(:order_item,
                                   order: order,
                                   catalog_item: catalog_item_with_pack,
                                   amount: 3,
                                   total: 24)

        order.order_items << build(:order_item,
                                   order: order,
                                   catalog_item: access_item,
                                   amount: 2,
                                   total: 4)

        order.order_items << build(:order_item,
                                   order: order,
                                   catalog_item: credit_b.catalog_item,
                                   amount: 5,
                                   total: 15)
        order.order_items.first.catalog_item.catalogable.catalog_items_included(true)
        order.save

        coc = CustomerCreditOrderCreator.new
        coc.save(order)
        expect(CustomerCredit.count).to eq(2)

        customer_credit = CustomerCredit.order(created_at: :desc).first
        expect(customer_credit.amount).to eq(5.0)
        expect(customer_credit.refundable_amount).to eq(5.0)
        expect(customer_credit.final_balance).to eq(20.0)
        expect(customer_credit.final_refundable_balance).to eq(17.0)
        expect(customer_credit.credit_value).to eq(3.0)
        expect(customer_credit.payment_method).to eq("none")
      end
    end
  end
end
