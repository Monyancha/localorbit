#!/usr/bin/env ruby
require '../config/environment'

$:.unshift "#{File.dirname(__FILE__)}/etl"

require './order_source'
require './order_destination'

trans_url = 'dbname=local_orbit_development user=andyb password=i81u812 host=localhost port=5432'
#trans_url = 'postgres://andyb:i81u812@127.0.0.1/local_orbit_development'

source OrderSource, trans_url

start_time = Time.now
num_rows = 0

pre_process do
  puts "*** START ORDER MIGRATION #{start_time}***"
end

transform do |row|
  num_rows = num_rows + 1
  newrow = {}
  newrow[:order_item_id] =            row[:order_item_id]
  newrow[:market] =                   row[:market]
  newrow[:market_city] =              row[:market_city]
  newrow[:market_state] =             row[:market_state]
  newrow[:market_zip] =               row[:market_zip]
  newrow[:market_country] =           row[:market_country]
  newrow[:placed_on] =                row[:placed_on]
  newrow[:order_number] =             row[:order_number]
  newrow[:buyer] =                    row[:buyer]
  newrow[:buyer_city] =               row[:buyer_city]
  newrow[:buyer_state] =              row[:buyer_state]
  newrow[:buyer_zip] =                row[:buyer_zip]
  newrow[:buyer_country] =            row[:buyer_country]
  newrow[:product] =                  row[:product]
  newrow[:short_description] =        row[:short_description]
  newrow[:product_code] =             row[:product_code]
  newrow[:product_category] =         row[:product_category]
  newrow[:supplier] =                 row[:supplier]
  newrow[:supplier_city] =            row[:supplier_city]
  newrow[:supplier_state] =           row[:supplier_state]
  newrow[:supplier_zip] =             row[:supplier_zip]
  newrow[:supplier_country] =         row[:supplier_country]
  newrow[:quantity] =                 row[:quantity]
  newrow[:unit] =                     row[:unit]
  newrow[:unit_description] =         row[:unit_description]
  newrow[:unit_price] =               row[:unit_price]
  newrow[:gross_price] =              row[:gross_price]
  newrow[:actual_discount] =          row[:actual_discount]
  newrow[:net_price] =                row[:net_price]
  newrow[:delivery_status] =          row[:delivery_status]
  newrow[:delivery_datetime] =        row[:delivery_datetime]
  newrow[:shipping_terms] =           row[:shipping_terms]
  newrow[:delivery_city] =            row[:delivery_city]
  newrow[:delivery_state] =           row[:delivery_state]
  newrow[:delivery_zip] =             row[:delivery_zip]
  newrow[:delivery_country] =         row[:delivery_country]
  newrow[:buyer_payment_status] =     row[:buyer_payment_status]
  newrow[:supplier_payment_status] =  row[:supplier_payment_status]

  newrow
end

post_process do
  end_time = Time.now
  duration_in_minutes = (end_time - start_time)/60
  puts "*** End ORDER MIGRATION #{end_time}***"
  puts "*** Duration (min): #{duration_in_minutes.round(2)}"
  puts "*** Rows Processed: #{num_rows}"
end

dw_url = 'dbname=local_orbit_development_dw user=andyb password=i81u812 host=localhost port=5432'
#dw_url = 'postgres://andyb:i81u812@127.0.0.1/local_orbit_development_dw'

destination OrderDestination, dw_url