class OrderHistoryActivityPresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::NumberHelper

  attr_reader :activities

  def initialize(activities)
    @activities = activities
  end

  def who
    output = ""
    if metadata.masquerader
      output += link_to_if(metadata.masquerader, metadata.masquerader_username, admin_user_path(metadata.masquerader))
      output += "<br>impersonating<br>"
    end
    output += link_to_if(metadata.user, metadata.user_name_or_email, admin_user_path(metadata.user))
    output.html_safe
  end

  def when
    metadata.display_date
  end

  def actions
    return @list if defined?(@list)

    @list = []
    if activities.any?{|a| a.auditable_type == "Order" && a.action == "create" }
      @list << "Order Placed"
      @list << process(activities.reject{|a| %w(Order OrderItem).include?(a.auditable_type) })
    else
      @list << process(activities)
    end

    @list = @list.flatten.compact
  end

  private

  def process(list)
    list.map do |item|
      case item.auditable_type
      when "Order"
        process_order(item)
      when "OrderItem"
        process_order_item(item)
      when "Payment"
        process_payment(item)
      else
        nil
      end
    end
  end

  def process_order(item)
    data = []
    payment_status = last_value_for_change(item, "payment_status")
    if payment_status && payment_status != "pending"
      data << "Buyer Payment Status: #{payment_status.humanize.capitalize}"
    end

    if last_value_for_change(item, "invoiced_at").present?
      data << "Order Invoiced"
    end

    data
  end

  def process_order_item(item)
    return unless item.auditable
    item_name = "#{item.auditable.name}, #{item.auditable.unit} from #{item.auditable.seller_name}"

    if item.auditable.delivery_status == "canceled"
      "Item Cancelled: #{item_name}"
    elsif item.audited_changes["quantity"].present?
      "Item Quantity Updated: #{item_name} (#{last_value_for_change(item, "quantity")})"
    elsif item.action == "create"
      "Item Added: #{item_name}"
    elsif last_value_for_change(item, "delivery_status") == "delivered"
      "Item Delivered: #{item_name}"
    end
  end

  def process_payment(item)
    payment_type = last_value_for_change(item, "payment_type")
    payment_method = last_value_for_change(item, "payment_method")
    payee_name = item.auditable.payee.try(:name)

    if payment_type == "seller payment"
      "Seller Payment Status: #{payment_method.humanize.capitalize} (#{payee_name})"
    elsif payment_type == "order refund"
      "Refunded #{payment_method.humanize.capitalize} #{number_to_currency(item.auditable.amount)}"
    end
  end

  def last_value_for_change(item, key)
    Array(item.audited_changes[key]).last
  end

  def metadata
    activities.first.decorate
  end
end