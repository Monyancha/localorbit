class CreateStripeSubscriptionForEntity
  include Interactor

  def perform
    # Initialize
    subscription_params = context[:subscription_params]
    entity = context[:entity]
    customer = PaymentProvider::Stripe.get_stripe_customer(context[:stripe_customer].id)

    # If the customer has any subscriptions...
    if customer.subscriptions.data.any?
      # ...cycle through them
      customer.subscriptions.data.each do |sub|
        # If any match the current data...
        if sub.plan.id = subscription_params[:plan]
          # ...then update the subscription:
          subscription        = customer.subscriptions.retrieve(sub.id)
          subscription.plan   = subscription_params[:plan]
          subscription.source = subscription_params[:stripe_tok]
          subscription.coupon = subscription_params[:coupon] if !subscription_params[:coupon].blank?
          subscription.save

        else
          # ...otherwise, delete the plan:
          customer.subscriptions.retrieve(sub.id).delete
        end
      end

    # Otherwise... 
    else
      # ...just create one
      subscription = customer.subscriptions.create(stripe_subscription_info)
    end

    context[:subscription] = subscription
    invoices = PaymentProvider::Stripe.get_stripe_invoices(:customer => subscription.customer) 
    context[:invoice] = invoices.data[0]
    
  rescue => e
    context.fail!(error: e.message)
  end

  def stripe_subscription_info
    ret_val = {
      plan: subscription_params[:plan],
      source: market_params[:stripe_tok],
      metadata: {
        "lo.entity_id" => entity.id,
        "lo.entity_type" => entity.class.name.underscore
      }
    }
    # Stripe complains if you pass an empty coupon.  Only add it if it exists 
    ret_val.tap do |r|
      r[:coupon] = subscription_params[:coupon] if !subscription_params[:coupon].blank?
    end
  end
end