class ReportsController < ApplicationController
  def index
    authorize :report

    @stats = calculate_stats
  end

  private

  def calculate_stats
    end_date = Time.current.end_of_day
    start_date = 30.days.ago.beginning_of_day
    prev_start_date = 60.days.ago.beginning_of_day
    prev_end_date = 31.days.ago.end_of_day

    # Current period
    current_orders = Order.where(created_at: start_date..end_date)
    current_order_count = current_orders.count
    current_customer_count = current_orders.distinct.count(:customer_id)
    current_total_value = Money.new(current_orders.sum(:total_amount_cents))

    # Previous period
    prev_orders = Order.where(created_at: prev_start_date..prev_end_date)
    prev_order_count = prev_orders.count
    prev_customer_count = prev_orders.distinct.count(:customer_id)
    prev_total_value = Money.new(prev_orders.sum(:total_amount_cents))

    # Breakdown by Inventory Group
    # This is a bit more complex as we need to join order_items and inventory_items
    breakdown = OrderItem.joins(inventory_item: :inventory_group)
                         .joins(:order)
                         .where(orders: { created_at: start_date..end_date })
                         .group("inventory_groups.name")
                         .sum(Arel.sql("order_items.price_cents * order_items.quantity"))

    total_cents = current_total_value.cents
    breakdown_data = breakdown.map do |name, cents|
      percentage = total_cents.zero? ? 0 : (cents.to_f / total_cents * 100).round(1)
      [ name, { value: Money.new(cents), percentage: percentage } ]
    end.to_h

    # Graph data: Orders over time (daily)
    daily_data = Order.where(created_at: start_date..end_date)
                      .group(Arel.sql("DATE(created_at)"))
                      .order(Arel.sql("DATE(created_at)"))
                      .pluck(Arel.sql("DATE(created_at)"), Arel.sql("COUNT(*)"), Arel.sql("SUM(total_amount_cents)"))

    # Fill in missing days if any
    dates = (start_date.to_date..end_date.to_date).to_a
    daily_map = daily_data.to_h { |d, c, s| [ d.to_s, { count: c, total: Money.new(s || 0) } ] }

    chart_data = dates.map do |date|
      {
        date: date.strftime("%b %d"),
        count: daily_map[date.to_s]&.[](:count) || 0,
        total: daily_map[date.to_s]&.[](:total)&.to_f || 0.0
      }
    end

    {
      current: {
        order_count: current_order_count,
        customer_count: current_customer_count,
        total_value: current_total_value
      },
      previous: {
        order_count: prev_order_count,
        customer_count: prev_customer_count,
        total_value: prev_total_value
      },
      changes: {
        order_count: percentage_change(current_order_count, prev_order_count),
        customer_count: percentage_change(current_customer_count, prev_customer_count),
        total_value: percentage_change(current_total_value.cents, prev_total_value.cents)
      },
      breakdown: breakdown_data,
      chart_data: chart_data,
      order_value_data: chart_data.map { |d| { label: d[:date], value: d[:total] } },
      order_count_data: chart_data.map { |d| { label: d[:date], value: d[:count] } }
    }
  end

  def percentage_change(current, previous)
    return 0 if previous.to_f.zero?
    (((current - previous).to_f / previous) * 100).round(1)
  end
end
