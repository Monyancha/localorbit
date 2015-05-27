describe PaymentProvider do
  # subject { described_class } 

  describe ".for" do
    it "returns the mapped provider object" do
      expect(PaymentProvider.for(:stripe)).to be(PaymentProvider::Stripe)
      expect(PaymentProvider.for(:balanced)).to be(PaymentProvider::Balanced)
    end

    it "accepts string identifiers as well as symbols" do
      expect(PaymentProvider.for('stripe')).to be(PaymentProvider::Stripe)
      expect(PaymentProvider.for('balanced')).to be(PaymentProvider::Balanced)
    end

    it "raises for unknown providers" do
      expect(lambda { PaymentProvider.for('wat') }).to raise_error(/wat/i)
    end
  end

  describe ".is_balanced?" do
    it "returns true if the given identifier corresponds to Balanced, false otherwise" do
      expect(PaymentProvider.is_balanced?(PaymentProvider::Balanced.id)).to be true
      expect(PaymentProvider.is_balanced?(:balanced)).to be true
      expect(PaymentProvider.is_balanced?('balanced')).to be true
      expect(PaymentProvider.is_balanced?(PaymentProvider::Stripe.id)).to be false
      expect(PaymentProvider.is_balanced?(:other)).to be false
      expect(PaymentProvider.is_balanced?(nil)).to be false
    end
  end


  [
    PaymentProvider::Balanced.id,
    PaymentProvider::Stripe.id,

  ].each do |provider_name|
    provider_object = PaymentProvider.for(provider_name)


    describe ".supports_payment_method?" do
      it "checks the provider for supported payment methods and returns true or false" do
        provider_object.supported_payment_methods.each do |good|
          expect(PaymentProvider.supports_payment_method?(provider_name, good)).to eq true
        end
        expect(PaymentProvider.supports_payment_method?(provider_name, :no_chance)).to eq false
        expect(PaymentProvider.supports_payment_method?(provider_name, nil)).to eq false
      end
    end

    describe ".can_add_payment_method?" do
      it "checks the provider for supported payment methods and returns true or false" do
        provider_object.addable_payment_methods.each do |good|
          expect(PaymentProvider.supports_payment_method?(provider_name, good)).to eq true
        end
        expect(PaymentProvider.supports_payment_method?(provider_name, :no_chance)).to eq false
        expect(PaymentProvider.supports_payment_method?(provider_name, nil)).to eq false
      end
    end

    describe ".place_order" do
      let(:params) {
        { buyer_organization: 'the buyer', 
          user: 'the user', 
          order_params: 'the order', 
          cart: 'the cart' }
      }
      it "delegates to #{provider_object.name}.place_order" do
        expect(provider_object).to receive(:place_order).with(params)
        PaymentProvider.place_order provider_name, params
      end
    end

    describe ".translate_status" do
      let(:params) {
        { charge: 'the charge', 
          payment_method: 'the payment method', 
          amount: 'the amount' }
      }
      it "delegates to #{provider_object.name}.translate_status" do
        expect(provider_object).to receive(:translate_status).with(params)
        PaymentProvider.translate_status provider_name, params
      end
      it "tolerates missing :amount and :payment_method fields" do
        expect(provider_object).to receive(:translate_status).with(charge: 'bull', amount:nil, payment_method:nil)
        PaymentProvider.translate_status provider_name, charge: 'bull'
      end
    end

    describe ".charge_for_order" do
      let(:params) {
        { amount: 'the amount', 
          bank_account: 'the bank account', 
          market: 'the market',
          order: 'the order',
          buyer_organization: 'the buyer organization' }
      }
      it "delegates to #{provider_object.name}.charge_for_order" do
        expect(provider_object).to receive(:charge_for_order).with(params)
        PaymentProvider.charge_for_order provider_name, params
      end
    end

    describe ".fully_refund" do
      let(:params) {
        { charge: 'the charge', 
          order: 'the order',
          payment: 'the payment' }
      }
      it "delegates to #{provider_object.name}.fully_refund" do
        expect(provider_object).to receive(:fully_refund).with(params)
        PaymentProvider.fully_refund provider_name, params
      end
      
      it "defaults :charge to nil if omitted" do
        expected = params.dup
        expected[:charge] = nil

        params.delete(:charge)

        expect(provider_object).to receive(:fully_refund).with(expected)
        PaymentProvider.fully_refund provider_name, params
      end
    end

    describe ".store_payment_fees" do
      let(:params) { { order: "the order" } }

      it "delegates to #{provider_object.name}.store_payment_fees" do
        expect(provider_object).to receive(:store_payment_fees).with(params)
        PaymentProvider.store_payment_fees provider_name, params
      end
    end

    describe ".create_order_payment" do
      let(:params) { 
        { 
          charge: 'the charge',
          market_id: 'the market_id',
          bank_account: 'the bank_account',
          payer: 'the payer',
          payment_method: 'the payment method',
          amount: 'the amount',
          order: 'the order',
          status: 'the status'
        } 
      }

      it "delegates to #{provider_object.name}.create_order_payment" do
        expect(provider_object).to receive(:create_order_payment).with(params)
        PaymentProvider.create_order_payment provider_name, params
      end
    end

    describe ".create_refund_payment" do
      let(:params) { 
        { 
          charge: 'the charge',
          market_id: 'the market_id',
          bank_account: 'the bank_account',
          payer: 'the payer',
          payment_method: 'the payment method',
          amount: 'the amount',
          order: 'the order',
          status: 'the status',
          refund: 'the refund',
          parent_payment: 'the parent payment'
        } 
      }

      it "delegates to #{provider_object.name}.create_refund_payment" do
        expect(provider_object).to receive(:create_refund_payment).with(params)
        PaymentProvider.create_refund_payment provider_name, params
      end
    end

    describe ".find_charge" do
      let(:params) { 
        { 
          payment: 'the payment'
        } 
      }

      it "delegates to #{provider_object.name}.find_charge" do
        expect(provider_object).to receive(:find_charge).with(params)
        PaymentProvider.find_charge provider_name, params
      end
    end

    describe ".refund_charge" do
      let(:params) { 
        { 
          charge: 'the charge',
          amount: 'the amount',
          order: 'the order'
        } 
      }

      it "delegates to #{provider_object.name}.refund_charge" do
        expect(provider_object).to receive(:refund_charge).with(params)
        PaymentProvider.refund_charge provider_name, params
      end
    end

    describe ".add_payment_method" do
      let(:params) {
        { type: 'the type', 
          entity: 'the entity', 
          bank_account_params: 'the bank acct params', 
          representative_params: 'the rep params' }
      }
      it "delegates to #{provider_object.name}.add_payment_method" do
        expect(provider_object).to receive(:add_payment_method).with(params)
        PaymentProvider.add_payment_method provider_name, params
      end
    end

    describe ".select_usable_bank_accounts" do
      let(:params) { "the bank accounts" }
      it "delegates to #{provider_object.name}.select_usable_bank_accounts" do
        expect(provider_object).to receive(:select_usable_bank_accounts).with(params)
        PaymentProvider.select_usable_bank_accounts provider_name, params
      end
    end

  end # end each provider loop
end

