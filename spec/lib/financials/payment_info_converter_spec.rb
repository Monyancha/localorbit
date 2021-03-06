require 'spec_helper'

describe Financials::PaymentInfoConverter do
  let(:converter) { described_class }

  let(:order_time) { Time.zone.parse("May 20, 2014 2:00 PM") }
  let(:deliver_time) { Time.zone.parse("May 25, 2014 3:30 PM") }
  let(:now_time) { Time.zone.parse("May 30, 2014 1:15 AM") }

  let!(:m1) { Generate.market_with_orders(
                order_time: order_time, 
                deliver_time: deliver_time,
                items: 3,
                paid_with: "credit card",
                delivered: "delivered",
                delivery_fee_percent: 13.to_d
  )}

  #
  # Payments to Sellers
  #
  #
  describe ".seller_net_payment_info" do
    # let(:order_items) { m1[:orders].first.items }

    let(:seller) { m1[:seller_organizations].first }
    let(:seller_orders) { Order.for_seller(seller.users.first) }
    let(:seller_section) { 
      Financials::SellerPayments::Builder.build_seller_section(
        seller_organization: seller,
        seller_orders: seller_orders
      )}
    let(:bank_account_id) { seller_section[:payable_accounts_for_select][0][1] }
    let(:total_amount) { seller_section[:seller_totals][:net_sales] }
    let(:order_ids) { seller_section[:order_rows].map { |r| r[:order_id] } }
    let(:market) { m1[:market] }

    it "loads Payment-relevant data based on the SellerSection and bank acct" do
      payment_info = converter.seller_net_payment_info(
        seller_section: seller_section, 
        bank_account_id: bank_account_id
      )
      expect(payment_info[:payee]).to eq(seller)
      expect(payment_info[:bank_account]).to eq(BankAccount.find(bank_account_id))
      expect(payment_info[:amount]).to eq(total_amount.round(2))
      expect(payment_info[:market]).to eq(market)
      expect(payment_info[:orders]).to contain_exactly(*Order.find(order_ids))
    end

    context "for a BankAccount that isn't include in the SellerSection" do
      let(:unverified_bank_account) { seller.bank_accounts.unverified.first || raise("I need an unverified BankAccount for this test") }
      it "raises" do
        expect do 
          converter.seller_net_payment_info(
            seller_section:seller_section,
            bank_account_id:unverified_bank_account.id)
        end.to raise_error(/not a payable bank account/i)
      end
    end

    context "for a BankAccount that isn't the Seller's" do
      let(:other_bank_account) { create(:bank_account) }
      it "raises" do
        expect do 
          converter.seller_net_payment_info(
            seller_section: seller_section,
            bank_account_id: other_bank_account.id)
        end.to raise_error(/not a payable bank account/i)
      end
    end
  end

  #
  # Payments to markets (market fees, delivery fees)
  #

  {
    market_hub_fee_payment_info: :market_fee,
    market_delivery_fee_payment_info: :delivery_fee,
  }.each do |(method_sym, payment_total_key)|

    describe ".#{method_sym}" do
      let(:market) { m1[:market] }
      let(:orders) { m1[:orders] }

      let(:market_section) { 
        Financials::MarketPayments::Builder.build_market_section(
          market: market,
          orders: orders
        )}

      let(:bank_account_id) { market_section[:payable_accounts_for_select][0][1] }
      let(:total_amount) { market_section[:market_totals][payment_total_key] }
      let(:order_ids) { market_section[:order_rows].map { |r| r[:order_id] } }

      it "loads Payment-relevant data based on the MarketSection and bank acct" do
        payment_info = converter.send(method_sym,
          market_section: market_section, 
          bank_account_id: bank_account_id
        )
        expect(payment_info[:payee]).to eq(market)
        expect(payment_info[:bank_account]).to eq(BankAccount.find(bank_account_id))
        expect(payment_info[:amount]).to eq(total_amount.round(2))
        expect(payment_info[:market]).to eq(market)
        expect(payment_info[:orders]).to contain_exactly(*Order.find(order_ids))
      end

      context "for a BankAccount that isn't include in the MarketSection" do
        let!(:unverified_bank_account) { 
          acct = market.bank_accounts.first
          acct.update(verified: false)
          acct
        }
        it "raises" do
          expect do 
            converter.send(method_sym,
              market_section: market_section,
              bank_account_id: unverified_bank_account.id)
          end.to raise_error(/not a payable bank account/i)
        end
      end
      
      context "for a BankAccount that isn't the Market's" do
        let(:other_bank_account) { create(:bank_account) }
        it "raises" do
          expect do 
            converter.send(method_sym,
              market_section: market_section,
              bank_account_id: other_bank_account.id)
          end.to raise_error(/not a payable bank account/i)
        end
      end
    end
  end
end
