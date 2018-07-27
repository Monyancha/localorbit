class OrderMailer < BaseMailer
  def buyer_confirmation(order)
    return if order.market.is_consignment_market?
    to_list = recipient_list(order.organization)
    return if to_list.blank?

    @market = order.market
    @order = BuyerOrder.new(order)

    mail(
      to: to_list,
      subject: 'Thank you for your order'
    )
  end

  def seller_confirmation(order, seller)
    return if order.market.is_consignment_market?
    to_list = recipient_list(seller)
    return if to_list.blank?

    @market = order.market
    @order = SellerOrder.new(order, seller) # Selling users organizations only see
    @seller = seller

    mail(
      to: to_list,
      subject: "New order on #{@market.name}"
    )
  end

  def market_manager_confirmation(order)
    return if order.market.is_consignment_market?

    @market = order.market
    @order = BuyerOrder.new(order) # Market Managers should see all items

    mail(
      to: order.market.managers.map(&:pretty_email),
      subject: "New order on #{@market.name}"
    )
  end

  def invoice(order_id)
    @order  = BuyerOrder.new(Order.find(order_id))
    return if @order.blank? || @order.market.is_consignment_market?
    to_list = recipient_list(@order.organization)
    return if to_list.blank?

    @market = @order.market

    attachments['invoice.pdf'] = {mime_type: 'application/pdf', content: @order.invoice_pdf.try(:data)}

    mail(
      to: to_list,
      subject: 'New Invoice'
    )
  end

  def buyer_order_updated(order)
    return if order.market.is_consignment_market?
    to_list = recipient_list(order.organization)
    return if to_list.blank?

    @market = order.market
    @order = BuyerOrder.new(order) # Market Managers should see all items

    mail(
      to: to_list,
      subject: "#{@market.name}: Order #{order.order_number} Updated",
      template_name: 'order_updated'
    )
  end

  def buyer_order_removed(order)
    return if order.market.is_consignment_market?
    to_list = recipient_list(order.organization)
    return if to_list.blank?

    @market = order.market
    @order = BuyerOrder.new(order) # Market Managers should see all items

    mail(
        to: to_list,
        subject: "#{@market.name}: Order #{order.order_number} Updated - Item Removed",
        template_name: 'order_updated'
    )
  end

  def seller_order_updated(order, seller)
    return if order.market.is_consignment_market?
    to_list = recipient_list(seller)
    return if to_list.blank?

    @market = order.market
    @order = SellerOrder.new(order, seller) # Selling users organizations only see
    @seller = seller

    mail(
      to: to_list,
      subject: "#{@market.name}: Order #{order.order_number} Updated",
      template_name: 'order_updated'
    )
  end

  def market_manager_order_updated(order)
    return if order.market.is_consignment_market?

    @market = order.market
    @order = BuyerOrder.new(order) # Market Managers should see all items

    mail(
      to: order.market.managers.map(&:pretty_email),
      subject: "#{@market.name}: Order #{order.order_number} Updated",
      template_name: 'order_updated'
    )
  end

  def seller_order_item_removal(order, seller)
    return if order.market.is_consignment_market?
    to_list = recipient_list(seller)
    return if to_list.blank?

    @market = order.market
    @order = SellerOrder.new(order, seller) # Selling users organizations only see
    @seller = seller

    mail(
      to: to_list,
      subject: "#{@market.name}: Order #{order.order_number} Updated - Item Removed",
      template_name: 'order_updated'
    )
  end

  private

  def recipient_list(organization)
    organization.
      users.
      confirmed.
      map { |u| u.enabled_for_organization?(organization) ? u.pretty_email : nil}.
      compact
  end
end
