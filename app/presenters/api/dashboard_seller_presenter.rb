class Api::DashboardSellerPresenter
  include Dashboards
  include ActiveSupport::NumberHelper

  def initialize(orders, interval, date_param, user)
    @orders = orders
    @interval = interval
    @date_param = date_param
    @user = user
  end

  def generate

    total_sales_amount_orders = @orders.placed_between(@interval)

    case @date_param
      when "0"
        total_sales_grouped = group_to_sellers(total_sales_amount_orders, 'hour')
      when "1"
        total_sales_grouped = group_to_sellers(total_sales_amount_orders, 'day')
      when "2"
        total_sales_grouped = group_to_sellers(total_sales_amount_orders, 'day', 'mtd')
      when "3"
        total_sales_grouped = group_to_sellers(total_sales_amount_orders, 'month')
      else
        total_sales_grouped = group_to_sellers(total_sales_amount_orders, 'day')
    end

    graph_labels = total_sales_grouped[:grp].as_json
    total_sales_amount_graph = total_sales_grouped[:total].as_json
    total_order_count_graph = total_sales_grouped[:count].as_json

    total_order_count = total_sales_amount_orders.count

    total_sales_amount_raw = sum_money_to_sellers(total_sales_amount_orders, @user)
    total_sales_amount = number_to_currency(total_sales_amount_raw, precision:0)

    average_sales_amount = total_order_count > 0 ? number_to_currency(total_sales_amount_raw/total_order_count || 0, precision:0) : '$0'

    payments_orders = @orders.paid_with("purchase order").delivered.unpaid.payment_overdue

    payments_due_amount = number_to_currency(sum_money_to_sellers(payments_orders, @user), precision:0)

    {
      :graph_labels => graph_labels,
      :total_sales_amount_graph => total_sales_amount_graph,
      :total_sales_amount => total_sales_amount ? total_sales_amount : '$0',
      :total_order_count_graph => total_order_count_graph,
      :total_order_count => total_order_count ? total_order_count : '0',
      :average_sales_amount => average_sales_amount ? average_sales_amount : '$0',
      :payments_due_amount => payments_due_amount ?  payments_due_amount : '$0'
    }

  end

end