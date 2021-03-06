require "spec_helper"

describe Market do

  subject{create(:market,)}
  describe "validates" do
    let(:original_market) { create(:market) }

    describe "name" do
      it "must be present" do
        market = build(:market)
        market.name = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:name)
      end

      it "is unique" do
        market = build(:market)
        market.name = original_market.name

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:name)
      end

      it "is less than 255 characters" do
        market = build(:market)
        market.name = "a" * 256

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:name)
      end
    end

    describe "country" do
      it "must be present" do
        market = build(:market)
        market.country = nil

        expect(market).to_not be_valid
      end
    end

    describe "subdomain" do
      it "must be present" do
        market = build(:market)
        market.subdomain = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:subdomain)
      end

      it "is unique" do
        market = build(:market)
        market.subdomain = original_market.subdomain

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:subdomain)
      end

      it "is less than 255 characters" do
        market = build(:market)
        market.subdomain = "a" * 256

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:subdomain)
      end

      it "cannot be a reserved name" do
        market = build(:market)
        market.subdomain = "app"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:subdomain)
      end
    end

    it "tagline can be at most 255 characters" do
      market = build(:market)
      market.tagline = "a" * 256

      expect(market).to_not be_valid
      expect(market).to have(1).error_on(:tagline)
    end

    describe "local_orbit_seller_fee" do
      it "must be present" do
        market = build(:market)
        market.local_orbit_seller_fee = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:local_orbit_seller_fee)
      end

      it "must be positive" do
        market = build(:market)
        market.local_orbit_seller_fee = "-1"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:local_orbit_seller_fee)
      end

      it "must be less than 100" do
        market = build(:market)
        market.local_orbit_seller_fee = "100"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:local_orbit_seller_fee)
      end
    end

    describe "local_orbit_market_fee" do
      it "must be present" do
        market = build(:market)
        market.local_orbit_market_fee = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:local_orbit_market_fee)
      end

      it "must be positive" do
        market = build(:market)
        market.local_orbit_market_fee = "-1"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:local_orbit_market_fee)
      end

      it "must be less than 100" do
        market = build(:market)
        market.local_orbit_market_fee = "100"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:local_orbit_market_fee)
      end
    end

    describe "market_seller_fee" do
      it "must be present" do
        market = build(:market)
        market.market_seller_fee = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:market_seller_fee)
      end

      it "must be positive" do
        market = build(:market)
        market.market_seller_fee = "-1"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:market_seller_fee)
      end

      it "must be less than 100" do
        market = build(:market)
        market.market_seller_fee = "100"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:market_seller_fee)
      end
    end

    describe "credit_card_seller_fee" do
      it "must be present" do
        market = build(:market)
        market.credit_card_seller_fee = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:credit_card_seller_fee)
      end

      it "must be positive" do
        market = build(:market)
        market.credit_card_seller_fee = "-1"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:credit_card_seller_fee)
      end

      it "must be less than 100" do
        market = build(:market)
        market.credit_card_seller_fee = "100"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:credit_card_seller_fee)
      end
    end

    describe "credit_card_market_fee" do
      it "must be present" do
        market = build(:market)
        market.credit_card_market_fee = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:credit_card_market_fee)
      end

      it "must be positive" do
        market = build(:market)
        market.credit_card_market_fee = "-1"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:credit_card_market_fee)
      end

      it "must be less than 100" do
        market = build(:market)
        market.credit_card_market_fee = "100"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:credit_card_market_fee)
      end
    end

    describe "ach_seller_fee" do
      it "must be present" do
        market = build(:market)
        market.ach_seller_fee = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_seller_fee)
      end

      it "must be positive" do
        market = build(:market)
        market.ach_seller_fee = "-1"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_seller_fee)
      end

      it "must be less than 100" do
        market = build(:market)
        market.ach_seller_fee = "100"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_seller_fee)
      end
    end

    describe "ach_market_fee" do
      it "must be present" do
        market = build(:market)
        market.ach_market_fee = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_market_fee)
      end

      it "must be positive" do
        market = build(:market)
        market.ach_market_fee = "-1"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_market_fee)
      end

      it "must be less than 100" do
        market = build(:market)
        market.ach_market_fee = "100"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_market_fee)
      end
    end

    describe "ach_fee_cap" do
      it "must be present" do
        market = build(:market)
        market.ach_fee_cap = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_fee_cap)
      end

      it "must be positive" do
        market = build(:market)
        market.ach_fee_cap = "-1"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_fee_cap)
      end

      it "must be less than 10000" do
        market = build(:market)
        market.ach_fee_cap = "10000"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_fee_cap)
      end
    end

    context "po_payment_term" do
      it "can not be nil" do
        market = build(:market, po_payment_term: nil)

        expect(market).to have(2).error_on(:po_payment_term)
      end

      it "must be greater than or equal to 0" do
        market = build(:market, po_payment_term: -1)

        expect(market).to have(1).error_on(:po_payment_term)
      end

      it "must be less than a year" do
        market = build(:market, po_payment_term: 366)

        expect(market).to have(1).error_on(:po_payment_term)
      end
    end
  end

  describe "#store_closed_note" do
    it "stores text" do

      subject.store_closed_note = "We have closed this store."
      subject.save!
      subject.reload
      expect(subject.store_closed_note).to eq("We have closed this store.")
    end
  end


  describe "#fulfillment_locations" do
    let!(:market) { create(:market) }
    let!(:address1) { create(:market_address, market: market) }
    let!(:address2) { create(:market_address, market: market) }
    let(:default_name) { "Direct to seller" }
    subject { market.fulfillment_locations(default_name) }

    it "accepts a parameter as default option name" do
      expect(subject).to include([default_name, 0])
    end

    it "has market address names" do
      expect(subject).to include([address1.name, address1.id])
      expect(subject).to include([address2.name, address2.id])
    end
  end

  describe "domain" do
    let(:market) { build(:market) }

    it "is is the subdomain with the canonical domain" do
      expect(market.domain).to eq("#{market.subdomain}.#{Figaro.env.domain!}")
    end
  end

  describe "#seller_net_percent" do
    let(:market) { create(:market, credit_card_market_fee:1, credit_card_seller_fee:0, local_orbit_seller_fee:0, market_seller_fee:0, payment_provider:'stripe')}
    let(:market_cc_fees) { create(:market, credit_card_market_fee:0, credit_card_seller_fee:1, local_orbit_seller_fee:0, market_seller_fee:0, payment_provider:'stripe')}
    let(:market_other_fees_seller) { create(:market, credit_card_market_fee:0, credit_card_seller_fee:1, local_orbit_seller_fee:2, market_seller_fee:1, payment_provider:'stripe')} # todo maths
    let(:market_other_fees_none) { create(:market, credit_card_market_fee:1, credit_card_seller_fee:0, local_orbit_seller_fee:2, market_seller_fee:1, payment_provider:'stripe')} # todo maths

    it "results correctly with zeroes" do
      expect(market.seller_net_percent).to eq(BigDecimal.new("1.00"))
    end

    it "uses payment processing correctly" do
      expect(market_cc_fees.seller_net_percent).to eq(BigDecimal.new("1.00")-BigDecimal.new("0.029"))
    end

    it "uses appropriate seller CC fees, given correct payment processing" do
      expect(market_other_fees_seller.seller_net_percent).to eq(BigDecimal.new("1.00")-BigDecimal.new("0.029")-BigDecimal.new("0.03"))
      expect(market_other_fees_none.seller_net_percent).to eq(BigDecimal.new("1.00")-BigDecimal.new("0.03"))

      market_other_fees_seller.local_orbit_seller_fee = 4
      expect(market_other_fees_seller.seller_net_percent).to eq(BigDecimal.new("1.00")-BigDecimal.new("0.029")-BigDecimal.new("0.05"))

      market_other_fees_none.market_seller_fee = 2
      expect(market_other_fees_none.seller_net_percent).to eq(BigDecimal.new("1.00")-BigDecimal.new("0.04"))
    end
  end

  describe "next_delivery" do
    let!(:market) { create(:market) }
    let!(:delivery_schedule) { create(:delivery_schedule, market: market) }

    it "builds and returns the next delivery" do
      delivery = market.next_delivery
      expect(delivery.delivery_schedule).to eq(delivery_schedule)
      expect(delivery.deliver_on).to be_future
      expect(delivery).to be_persisted
    end

    it "returns nil if there are no valid delivery schedules" do
      delivery_schedule.soft_delete
      expect(market.next_delivery).to be_nil
    end
  end

  describe "#last_service_payment_at" do
    subject {create(:organization, :market)}

    context "when no payments made" do
      it "returns nil if no payments made" do
        expect(subject.last_service_payment_at).to be_nil
      end
    end

    context "when payment(s) made" do
      let!(:payment_one) {create(:payment, :service, organization: subject, payer: subject, created_at: 1.year.ago.noon)}

      it "returns date of last payment when one payment made" do
        expect(subject.last_service_payment_at).to eq(payment_one.created_at)
      end

      it "returns date of last payment when multiple payments made" do
        create(:payment, :service, organization: subject, payer: subject, created_at: 368.day.ago.noon)

        expect(subject.last_service_payment_at).to eq(payment_one.created_at)
      end
    end
  end

  describe "#next_service_payment_at" do
    subject{create(:organization, :market)}

    it "returns nil if plan_start_at or plan_interval are not set" do
      subject.plan_start_at = nil
      subject.plan_interval = nil

      expect(subject.next_service_payment_at).to be_nil

      subject.plan_start_at = 1.minute.from_now
      expect(subject.next_service_payment_at).to be_nil

      subject.plan_start_at = 1.minute.ago
      expect(subject.next_service_payment_at).to be_nil

      subject.plan_start_at = nil
      subject.plan_interval = 1
      expect(subject.next_service_payment_at).to be_nil

      subject.plan_start_at = nil
      subject.plan_interval = 12
      expect(subject.next_service_payment_at).to be_nil
    end

    context "monthly plan" do
      subject { create(:organization, plan_interval: 1) }

      it "returns plan_start_at when plan starts in the future" do
        subject.plan_start_at = 1.day.from_now
        expect(subject.next_service_payment_at).to eq(subject.plan_start_at)
      end

      it "returns plan_start_at when no payments have been made" do
        subject.plan_start_at = 1.minute.ago.change(:sec => 0)
        expect(subject.next_service_payment_at).to eq(subject.plan_start_at)
      end

      it "returns plan_start_at when payments were made before the plan start" do
        create(:payment, :service, organization: subject, payer: subject, created_at: 1.year.ago)
        subject.plan_start_at = Time.current.change(:sec => 0)
        expect(subject.next_service_payment_at).to eq(subject.plan_start_at)
      end

      context "returns the next payment date based on previous successful plan payment" do
        let!(:payment_one) {create(:payment, :service, organization: subject, payer: subject, created_at: 58.days.ago.noon, status: "failed")}
        let!(:payment_two) {create(:payment, :service, organization: subject, payer: subject, created_at: 57.days.ago.noon)}
        before do
          subject.plan_start_at = 58.days.ago.noon
        end

        it "with 1 successful payment" do
          expect(subject.next_service_payment_at).to eq(1.month.from_now(payment_two.created_at))
        end
      end

      context "returns the correct next payment date when there are multiple previous payments" do
        let!(:payment_one) {create(:payment, :service, organization: subject, payer: subject, created_at: 58.days.ago.noon, status: "failed")}
        let!(:payment_two) {create(:payment, :service, organization: subject, payer: subject, created_at: 57.days.ago.noon)}
        let!(:payment_three) {create(:payment, :service, organization: subject, payer: subject, created_at: 28.days.ago.noon)}
        before do
          subject.plan_start_at = 58.days.ago.noon
        end

        it "with 2 successful payments" do
          expect(subject.next_service_payment_at).to eq(1.months.from_now(payment_three.created_at))
        end
      end
    end

    context "yearly plan" do
      subject { create(:organization, :market, plan_interval: 12) }

      it "returns plan_start_at when plan starts in the future" do
        subject.plan_start_at = 1.day.from_now.change(:sec => 0)
        expect(subject.next_service_payment_at).to eq(subject.plan_start_at)
      end

      it "returns plan_start_at when no payments have been made" do
        subject.plan_start_at = 1.minute.ago.change(:sec => 0)
        expect(subject.next_service_payment_at).to eq(subject.plan_start_at)
      end

      it "returns plan_start_at when payments were made before the plan start" do
        create(:payment, :service, organization: subject, payer: subject, created_at: 1.week.ago)
        subject.plan_start_at = Time.current.change(:sec => 0)
        expect(subject.next_service_payment_at).to eq(subject.plan_start_at)
      end

      context "returns the next payment date based on previous successful plan payment" do
        let!(:payment_maize) {create(:payment, :service, organization: subject, payer: subject, created_at: 375.days.ago.noon, status: "failed")}
        let!(:payment_blue) {create(:payment, :service, organization: subject, payer: subject, created_at: 374.days.ago.noon)}

        before do
          subject.plan_start_at = 375.days.ago.noon
        end

        it "with 1 successful payment" do
          expect(subject.next_service_payment_at).to eq(1.year.from_now(payment_blue.created_at))
        end
      end

      context "returns the correct next payment when there are multiple previous successful plan payments" do
        let!(:payment_maize) {create(:payment, :service, organization: subject, payer: subject, created_at: 375.days.ago.noon, status: "failed")}
        let!(:payment_blue) {create(:payment, :service, organization: subject, payer: subject, created_at: 374.days.ago.noon)}
        let!(:payment_green) {create(:payment, :service, organization: subject, payer: subject, created_at: 11.days.ago.noon)}

        before do
          subject.plan_start_at = 375.days.ago.noon
        end

        it "with 2 successful payments" do
          expect(subject.next_service_payment_at).to eq(1.years.from_now(payment_green.created_at))
        end
      end
    end
  end

  describe "changing plan" do
    context "disables cross-selling" do
      let!(:old_plan) { create(:plan, cross_selling: true) }
      let!(:new_plan) { create(:plan, cross_selling: false) }

      let!(:market_org1) {create(:organization, :market, plan: old_plan)}
      let!(:market1)  { create(:market, organization: market_org1, allow_cross_sell: true) }
      let!(:org1)     { create(:organization, :seller, markets: [market1]) }
      let!(:market_org2) {create(:organization, :market)}
      let!(:market2)  { create(:market, organization: market_org2) }
      let!(:org2)     { create(:organization, :seller, markets: [market2]) }

      before do
        # Member organization cross-selling on another market
        MarketOrganization.create(market_id: market2.id, organization_id: org1.id, cross_sell_origin_market_id: market1.id)

        # Non-member organization cross-selling on this market
        MarketOrganization.create(market_id: market1.id, organization_id: org2.id, cross_sell_origin_market_id: market2.id)

        market_org1.update(plan: new_plan)
      end

      it "disables other markets from seeing it as a cross selling market" do
        expect(market1.reload.allow_cross_sell).to eql(false)
      end

      it "removes any member organization from cross selling on other markets" do
        expect(MarketOrganization.where(cross_sell_origin_market_id: market1.id, deleted_at: nil).count).to eql(0)
      end

      it "removes any non-member organizations from cross selling on the market" do
        expect(MarketOrganization.where.not(cross_sell_origin_market_id: nil).where(market_id: market1.id, deleted_at: nil).count).to eql(0)
      end
    end

    context "updates the markets products" do
      let!(:old_plan) { create(:plan, advanced_inventory: true) }
      let!(:new_plan) { create(:plan, advanced_inventory: false) }

      let!(:market_org1) {create(:organization, :market, plan: old_plan)}
      let!(:market1)  { create(:market, organization: market_org1, allow_cross_sell: true) }
      let!(:org1)     { create(:organization, :seller, markets: [market1]) }
      let!(:product1) { create(:product, organization: org1, use_simple_inventory: false) }
      let!(:lot1)     { create(:lot, product: product1, quantity: 25) }
      let!(:lot2)     { create(:lot, product: product1, quantity: 35) }

      it "updates product inventory for a market downgrading service plan" do
        expect(product1.reload.lots.count).to eql(2)

        market_org1.update(plan: new_plan)

        expect(product1.reload.lots.count).to eql(1)
      end
    end
  end

  describe "#local_orbit_seller_and_market_fee_fraction" do
    let(:market) { create(:market, local_orbit_seller_fee: "1.0".to_d, local_orbit_market_fee: "2.0".to_d) }
    it "returns a combination of seller and market fees due LO divided by 100" do
      expect(market.local_orbit_seller_and_market_fee_fraction).to eq "0.03".to_d
    end
  end

  describe "#credit_card_payment_fee_payer" do
    let(:market) { create(:market) }
    [
      [{ credit_card_seller_fee: 0, credit_card_market_fee: 0 }, 'seller' ],
      [{ credit_card_seller_fee: 0, credit_card_market_fee: 1 }, 'market' ],
      [{ credit_card_seller_fee: 1, credit_card_market_fee: 0 }, 'seller' ],
      [{ credit_card_seller_fee: 1, credit_card_market_fee: 1 }, 'market' ],
    ].each do |(fees, payer)|
      it "returns #{payer.inspect} when fees are #{fees.inspect}" do
        market.update(fees)
        expect(market.credit_card_payment_fee_payer).to eq payer
      end
    end
  end

  describe "#set_credit_card_payment_fee_payer" do
    let(:market) { create(:market) }
    [
      [{ credit_card_seller_fee: 0, credit_card_market_fee: 1 }, 'market' ],
      [{ credit_card_seller_fee: 1, credit_card_market_fee: 0 }, 'seller' ],
    ].each do |(fees, payer)|
      it "sets the fees to #{fees.inspect} when set to #{payer.inspect}" do
        market.set_credit_card_payment_fee_payer(payer)
        fees.each do |field,val|
          expect(market[field]).to eq val
        end
        expect(market.ach_market_fee).to eq 0
        expect(market.ach_seller_fee).to eq 0
      end
    end
  end

  describe "#primary_payment_provider" do
    it "returns the payment_provider" do
      market = Market.new(payment_provider: "whatever")
      expect(market.payment_provider).to eq "whatever"
      expect(market.primary_payment_provider).to eq "whatever"
    end
  end

  describe "#stripe_account" do
    let(:stripe_account) { double("stripe account") }
    let(:market) { create(:market) }

    it "returns the StripeAccount" do
      market.update_attribute(:stripe_account_id, "acct id")
      expect(Stripe::Account).to receive(:retrieve).with(market.stripe_account_id).and_return(stripe_account)
      expect(market.stripe_account).to be stripe_account
    end

    context "when stripe_account_id is nil" do
      it "returns nil" do
        market.update_attribute(:stripe_account_id, nil)
        expect(Stripe::Account).not_to receive(:retrieve)
        expect(market.stripe_account).to be nil
      end
    end

    context "when account retrieval fails" do
      it "returns nil" do
        market.update_attribute(:stripe_account_id, "oops")
        expect(Stripe::Account).to receive(:retrieve)
          .with(market.stripe_account_id)
          .and_raise("nuked!")
        expect(market.stripe_account).to be nil
      end
    end
  end



end
