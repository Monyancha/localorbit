class AttemptAchPurchase
  include Interactor

  def perform
    if order_params["payment_method"] == 'ach' && order
      begin
        bank_account = cart.organization.bank_accounts.find(order_params["bank_account"])
        balanced_customer = Balanced::Customer.find(cart.organization.balanced_customer_uri)

        amount = (cart.total * 100).to_i #USD in cents

        debit = balanced_customer.debit(amount: amount, description: "#{cart.market.name} purchase", source_uri: bank_account.balanced_uri)

        context[:payment] = Payment.create(
          payer: buyer,
          payment_method: 'ach',
          amount: cart.total,
          status: "pending",
          balanced_uri: debit.uri,
          orders: [order]
        )

        order.update(payment_method: 'ach', payment_status: 'pending')

        if !context[:payment].persisted?
          debit.refund
          context.fail!
        end

      rescue Exception => e
        Honeybadger.notify_or_ignore(e) unless Rails.env.test? || Rails.env.development?

        context[:order].errors.add(:credit_card, "Payment processor error.")
        context.fail!
      end
    end
  end

  def rollback
    if context[:payment] && context[:payment][:payment_method] == 'ach'
      Balanced::Debit.find(payment.balanced_uri).refund
      context.delete(:payment)
    end
  end
end
