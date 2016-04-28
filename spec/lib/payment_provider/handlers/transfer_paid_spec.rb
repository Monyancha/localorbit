require 'spec_helper'

describe PaymentProvider::Handlers::TransferPaid do
  subject { described_class }

  describe '.extract_job_params' do
    it 'extracts the account and transfer ids' do
      event = double(user_id: 'account id')
      transfer = double(id: 'transfer id', amount: 'the pennies')
      allow(event).to receive_message_chain('data.object') { transfer }
      expect(subject.extract_job_params(event)).
        to eq(transfer_id: 'transfer id', stripe_account_id: 'account id', amount_in_cents: 'the pennies')
    end
  end

  describe '.handle' do
    let!(:user) { create(:user) }
    let!(:market) { create(:market, stripe_account_id: 'account id', managers: [user]) }
    let!(:market2) { create(:market) }

    it 'does nothing if no stripe_account_id is given' do
      expect(PaymentProvider::Stripe).to_not receive(:create_market_payment)
      expect(PaymentMailer).to_not receive(:payment_received)
      subject.handle(transfer_id: 'transfer id', stripe_account_id: nil, amount_in_cents: '1234')
      expect(Payment.count).to eq(0)
    end

    context 'when there is no Market connected with the given stripe_account_id' do
      it 'does nothing if no Market bears the given stripe_account_id' do
        market.update(stripe_account_id: 'will not match')
        expect(PaymentProvider::Stripe).to_not receive(:create_market_payment)
        expect(PaymentMailer).to_not receive(:payment_received)
        subject.handle(transfer_id: 'transfer id', stripe_account_id: 'account id', amount_in_cents: '1234')
        expect(Payment.count).to eq(0)
      end
    end

    it 'creates a market payment for the transfer amount and releated orders' do
      payment = double('the payment', id: 187, payee: market)
      expect(PaymentProvider::Stripe).to receive(:order_ids_for_market_payout_transfer).
        with(transfer_id: 'transfer id', stripe_account_id: 'account id').
        and_return(['123', '456'])
      expect(PaymentProvider::Stripe).to receive(:create_market_payment).
        with(transfer_id: 'transfer id', market: market, order_ids: ['123', '456'], 
             status:'paid', amount: '12.34'.to_d).
        and_return(payment)

      subject.handle(transfer_id: 'transfer id', stripe_account_id: 'account id', 
                     amount_in_cents: '1234')
    end

    describe "on error" do
      it "reports via Honeybadger" do
        payment = double('the payment', id: 187, payee: market)
        expect(PaymentProvider::Stripe).to receive(:order_ids_for_market_payout_transfer).
          with(transfer_id: 'transfer id', stripe_account_id: 'account id').
          and_return(['123', '456'])
        expect(PaymentProvider::Stripe).to receive(:create_market_payment).
          with(transfer_id: 'transfer id', market: market, order_ids: ['123', '456'], 
               status:'paid', amount: '12.34'.to_d).
          and_raise("Cain")

        expect(Financials::PaymentNotifier).not_to receive(:market_payment_received)

        expect(Honeybadger).to receive(:notify_or_ignore) do |e|
          expect(e.message).to match(/Error handling transfer.paid event/)
          data = e.data
          expect(data).to be
          expect(data[:exception][:message]).to eq('Cain')
          expect(data[:params]).to be
          expect(data[:params][:transfer_id]).to eq('transfer id')
          expect(data[:params][:stripe_account_id]).to eq('account id')
          expect(data[:params][:amount_in_cents]).to eq('1234')
        end

        subject.handle(transfer_id: 'transfer id', stripe_account_id: 'account id', 
                       amount_in_cents: '1234')


      end
    end

  end
end
