require "spec_helper"

feature "Payments to vendors" do
  let(:today) { 1.week.ago }

  let(:market1) { create(:market, name: "Baskerville Co-op", po_payment_term: 14) }
  let!(:market1_delivery_schedule) { create(:delivery_schedule, market: market1, day: (today - 3.day).wday) }
  let!(:market1_delivery) { Timecop.freeze(today - 5.days) { market1_delivery_schedule.next_delivery } }
  let!(:market_manager) { create :user, :market_manager, managed_markets: [market1] }

  let!(:market1_seller1) { create(:organization, :seller, name: "Better Farms", markets: [market1]) }
  let!(:market1_seller2) { create(:organization, :seller, name: "Great Farms", markets: [market1]) }
  let!(:market1_seller3) { create(:organization, :seller, name: "Betterest Farms", markets: [market1]) }
  let!(:market1_seller4) { create(:organization, :seller, name: "Greater Farms", markets: [market1]) }
  let!(:market1_buyer)  { create(:organization, :buyer, name: "Money Bags", markets: [market1]) }

  let!(:market1_product1) { create(:product, :sellable, organization: market1_seller1) }
  let!(:market1_product2) { create(:product, :sellable, organization: market1_seller2) }
  let!(:market1_product3) { create(:product, :sellable, organization: market1_seller2) }
  let!(:market1_product4) { create(:product, :sellable, organization: market1_seller3) }

  let!(:market1_order1) do
    create(:order,
           market: market1,
           organization: market1_buyer,
           delivery: market1_delivery,
           payment_method: "purchase order",
           order_number: "LO-001",
           total_cost: 12.00,
           placed_at: today - 19.days)
  end

  let!(:market1_order1_item1) do
    create(:order_item,
           :delivered,
           product: market1_product1,
           quantity: 4,
           order: market1_order1)
  end

  let!(:market1_order2) { create(:order, items: [create(:order_item, :delivered, product: market1_product2, quantity: 3), create(:order_item, :delivered, product: market1_product4, quantity: 7)], market: market1, organization: market1_buyer, delivery: market1_delivery, payment_method: "purchase order", order_number: "LO-002", total_cost: 69.90, placed_at: today - 6.days, payment_status: "paid") }
  let!(:market1_order3) { create(:order, items: [create(:order_item, :delivered, product: market1_product3, quantity: 6)], market: market1, organization: market1_buyer, delivery: market1_delivery, payment_method: "purchase order", order_number: "LO-003", total_cost: 41.94, placed_at: today - 4.days) }
  let!(:market1_order4) { create(:order, items: [create(:order_item, :delivered, product: market1_product2, quantity: 9), create(:order_item, :delivered, product: market1_product3, quantity: 14)], market: market1, organization: market1_buyer, delivery: market1_delivery, payment_method: "purchase order", order_number: "LO-004", total_cost: 160.77, placed_at: today - 3.days) }
  let!(:market1_order5) { create(:order, items: [create(:order_item, :delivered, product: market1_product2, quantity: 9), create(:order_item, :delivered, product: market1_product3, quantity: 14)], market: market1, organization: market1_buyer, delivery: market1_delivery, payment_method: "purchase order", order_number: "LO-005", total_cost: 160.77, placed_at: today - 80.days) }

  context "no discounts" do
    scenario "displays the correct items" do
      switch_to_subdomain(market1.subdomain)
      sign_in_as market_manager
      visit admin_financials_vendor_payments_path
      seller_rows = Dom::Admin::Financials::VendorPaymentRow.all

      expect(seller_rows.size).to eq(3)
      expect(seller_rows[0].name).to have_content("Better Farms")
      expect(seller_rows[0].order_count).to have_content(/\A1 order from Baskerville Co-op Review/)
      expect(seller_rows[0].owed).to have_content("$12.00")

      expect(seller_rows[1].name).to have_content("Betterest Farms")
      expect(seller_rows[1].order_count).to have_content(/\A1 order from Baskerville Co-op Review/)
      expect(seller_rows[1].owed).to have_content("$48.93")

      expect(seller_rows[2].name).to have_content("Great Farms")
      expect(seller_rows[2].order_count).to have_content(/\A3 orders from Baskerville Co-op Review/)
      expect(seller_rows[2].owed).to have_content("$223.68")
    end
  end

  context "discounts" do
    context "market pays discount" do
      let!(:discount) { create(:discount, type: "fixed", payer: "market", discount: 10.00) }

      before do
        market1_order1.update(discount: discount)
      end

      scenario "displays the correct items" do
        switch_to_subdomain(market1.subdomain)
        sign_in_as market_manager
        visit admin_financials_vendor_payments_path
        seller_row = Dom::Admin::Financials::VendorPaymentRow.all[0]

        expect(seller_row.name).to have_content("Better Farms")
        expect(seller_row.order_count).to have_content(/\A1 order from Baskerville Co-op Review/)
        expect(seller_row.owed).to have_content("$12.00")
      end
    end

    context "seller pays discount" do
      let!(:discount) { create(:discount, type: "fixed", payer: "seller", discount: 10.00) }

      before do
        market1_order1.update(discount: discount)
        market1_order1_item1.update(discount_seller: discount.discount)
      end

      scenario "displays the correct items" do
        switch_to_subdomain(market1.subdomain)
        sign_in_as market_manager
        visit admin_financials_vendor_payments_path
        seller_row = Dom::Admin::Financials::VendorPaymentRow.all[0]

        expect(seller_row.name).to have_content("Better Farms")
        expect(seller_row.order_count).to have_content(/\A1 order from Baskerville Co-op Review/)
        expect(seller_row.owed).to have_content("2.00")
      end
    end
  end

  scenario "de-selecting orders", :js do
    switch_to_subdomain(market1.subdomain)
    sign_in_as market_manager
    visit admin_financials_vendor_payments_path

    seller_row = Dom::Admin::Financials::VendorPaymentRow.for_seller("Great Farms")
    seller_row.review

    expect(page).to have_content('Hide Orders') # test waits for ajax to load here

    orders = Dom::Admin::Financials::VendorPaymentOrderRow.all

    expect(orders.size).to eq(3)
    expect(orders[0].order_number).to eq("LO-002")
    expect(orders[0].placed_at).to have_content(market1_order2.placed_at.strftime("%b %d, %Y"))
    expect(orders[0].total).to have_content("$20.97")

    expect(orders[1].order_number).to eq("LO-003")
    expect(orders[1].placed_at).to have_content(market1_order3.placed_at.strftime("%b %d, %Y"))
    expect(orders[1].total).to have_content("$41.94")

    expect(orders[2].order_number).to eq("LO-004")
    expect(orders[2].placed_at).to have_content(market1_order4.placed_at.strftime("%b %d, %Y"))
    expect(orders[2].total).to have_content("$160.77")

    expect(seller_row.selected_owed).to have_content("$223.68")

    orders[1].click_check

    expect(seller_row.selected_owed).to have_content("$181.74")
  end

  def seller_found?(boo)
    matches = Dom::Admin::Financials::VendorPaymentRow.all.select {|p| p.name.text == boo }
    matches.size > 0
  end

  scenario "mark all orders for seller paid", :js do
    switch_to_subdomain(market1.subdomain)
    sign_in_as market_manager
    visit admin_financials_vendor_payments_path
    seller_row = Dom::Admin::Financials::VendorPaymentRow.for_seller("Great Farms")
    seller_row.pay_all_now

    choose "Check"
    fill_in "Check #", with: "4234"

    within(".record-payment") do
      find_button("Record Payment").click
    end

    expect(page).to have_content("Payment of $223.68 recorded for Great Farms")

    # Great Farms should no longer be in the payments list
    assert !seller_found?("Great Farms")
  end

  scenario "mark selected orders for seller paid", :js do
    switch_to_subdomain(market1.subdomain)
    sign_in_as market_manager
    visit admin_financials_vendor_payments_path
    seller_row = Dom::Admin::Financials::VendorPaymentRow.for_seller("Great Farms")
    seller_row.review

    expect(page).to have_content('Hide Orders') # test waits for ajax to load here

    orders = Dom::Admin::Financials::VendorPaymentOrderRow.all
    orders[1].click_check

    seller_row.pay_selected

    choose "Check"
    fill_in "Check #", with: "4234"

    within(".record-payment") do
      click_button "Record Payment"
    end

    expect(page).to have_content("Payment of $181.74 recorded for Great Farms")

    # Great Farms should still be in the payments list
    assert seller_found?("Great Farms")

    seller_rows = Dom::Admin::Financials::VendorPaymentRow.all

    # With 1 order
    expect(seller_rows[2].name).to have_content("Great Farms")
    expect(seller_rows[2].order_count).to have_content(/\A1 order from Baskerville Co-op Review/)
    expect(seller_rows[2].owed).to have_content("$41.94")
  end

  context "filtering" do
    let(:market2) { create(:market, name: "Jonesville Co-op", po_payment_term: 14) }

    let!(:market3) { create(:market, name: "Not In List", po_payment_term: 14) }

    let!(:market1_delivery_schedule) { create(:delivery_schedule, market: market2, day: (today - 3.days).wday) }
    let!(:market2_delivery) { Timecop.freeze(today - 5.days) { market1_delivery_schedule.next_delivery } }
    let!(:market_manager) { create :user, :market_manager, managed_markets: [market1, market2] }

    let!(:market2_seller1) { create(:organization, :seller, name: "Best Farms", markets: [market2]) }
    let!(:market2_seller2) { create(:organization, :seller, name: "Fruit Farms", markets: [market2]) }
    let!(:market2_seller3) { create(:organization, :seller, name: "Vegetable Farms", markets: [market2]) }
    let!(:market2_seller4) { create(:organization, :seller, name: "Smith Farms", markets: [market2]) }
    let!(:market2_buyer)  { create(:organization, :buyer, name: "Institution", markets: [market2]) }

    let!(:market2_product1) { create(:product, :sellable, organization: market2_seller1) }
    let!(:market2_product2) { create(:product, :sellable, organization: market2_seller2) }
    let!(:market2_product3) { create(:product, :sellable, organization: market2_seller2) }
    let!(:market2_product4) { create(:product, :sellable, organization: market2_seller3) }

    let!(:market2_order1) { create(:order, items: [create(:order_item, :delivered, product: market2_product1, quantity: 4)], market: market2, organization: market2_buyer, delivery: market2_delivery, payment_method: "purchase order", order_number: "LO-006", total_cost: 12.00, placed_at: today - 19.days) }
    let!(:market2_order2) { create(:order, items: [create(:order_item, :delivered, product: market2_product2, quantity: 3), create(:order_item, :delivered, product: market2_product4, quantity: 7)], market: market2, organization: market2_buyer, delivery: market2_delivery, payment_method: "purchase order", order_number: "LO-007", total_cost: 69.90, placed_at: today - 6.days, payment_status: "paid") }
    let!(:market2_order3) { create(:order, items: [create(:order_item, :delivered, product: market2_product3, quantity: 6)], market: market2, organization: market2_buyer, delivery: market2_delivery, payment_method: "purchase order", order_number: "LO-0008", total_cost: 41.94, placed_at: today - 4.days) }
    let!(:market2_order4) { create(:order, items: [create(:order_item, :delivered, product: market2_product2, quantity: 9), create(:order_item, :delivered, product: market2_product3, quantity: 14)], market: market2, organization: market2_buyer, delivery: market2_delivery, payment_method: "purchase order", order_number: "LO-009", total_cost: 160.77, placed_at: today - 3.days) }

    let!(:market3_delivery_schedule) { create(:delivery_schedule, market: market3, day: (today - 3.days).wday) }
    let!(:market3_delivery) { Timecop.freeze(today - 5.days) { market1_delivery_schedule.next_delivery } }

    let!(:market3_seller1) { create(:organization, :seller, name: "Freshest Farm", markets: [market3]) }
    let!(:market3_seller2) { create(:organization, :seller, name: "Less Fresh Farm", markets: [market3]) }
    let!(:market3_seller3) { create(:organization, :seller, name: "Normal Farm", markets: [market3]) }
    let!(:market3_seller4) { create(:organization, :seller, name: "A few days behind farm", markets: [market3]) }
    let!(:market3_buyer)  { create(:organization, :buyer, name: "The Last Institution", markets: [market3]) }

    let!(:market3_product1) { create(:product, :sellable, organization: market3_seller1) }
    let!(:market3_product2) { create(:product, :sellable, organization: market3_seller2) }
    let!(:market3_product3) { create(:product, :sellable, organization: market3_seller2) }
    let!(:market3_product4) { create(:product, :sellable, organization: market3_seller3) }

    let!(:market3_order1) { create(:order, items: [create(:order_item, :delivered, product: market3_product1, quantity: 4)], market: market3, organization: market3_buyer, delivery: market3_delivery, payment_method: "purchase order", order_number: "LO-092", total_cost: 12.00, placed_at: today - 19.days) }
    let!(:market3_order2) { create(:order, items: [create(:order_item, :delivered, product: market3_product2, quantity: 3), create(:order_item, :delivered, product: market3_product4, quantity: 7)], market: market3, organization: market3_buyer, delivery: market3_delivery, payment_method: "purchase order", order_number: "LO-010", total_cost: 69.90, placed_at: today - 6.days, payment_status: "paid") }
    let!(:market3_order3) { create(:order, items: [create(:order_item, :delivered, product: market3_product3, quantity: 6)], market: market3, organization: market3_buyer, delivery: market3_delivery, payment_method: "purchase order", order_number: "LO-008", total_cost: 41.94, placed_at: today - 4.days) }
    let!(:market3_order4) { create(:order, items: [create(:order_item, :delivered, product: market3_product2, quantity: 9), create(:order_item, :delivered, product: market3_product3, quantity: 14)], market: market3, organization: market3_buyer, delivery: market3_delivery, payment_method: "purchase order", order_number: "LO-082", total_cost: 160.77, placed_at: today - 3.days) }

    context "market manager who has only 1 market" do
      let!(:market_manager) { create :user, :market_manager, managed_markets: [market1] }

      scenario "will not see market as a filter option" do
        switch_to_subdomain(market1.subdomain)
        sign_in_as market_manager
        visit admin_financials_vendor_payments_path

        expect(page).not_to have_select("Market")
      end
    end

    scenario "filtering by market" do
      switch_to_subdomain(market1.subdomain)
      sign_in_as market_manager
      visit admin_financials_vendor_payments_path

      expect(page).to have_select("Market")

      seller_rows = Dom::Admin::Financials::VendorPaymentRow.all
      expect(seller_rows.map {|r| r.name.text }).to eq(["Best Farms", "Better Farms", "Betterest Farms", "Fruit Farms", "Great Farms", "Vegetable Farms"])

      within("#q_market_id_in") do
        expect(page).to have_content(market1.name)
        expect(page).to have_content(market2.name)
        expect(page).not_to have_content(market3.name)
      end

      select market1.name, from: "q_market_id_in"
      click_button "Filter"

      seller_rows = Dom::Admin::Financials::VendorPaymentRow.all
      expect(seller_rows.map {|r| r.name.text }).to eq(["Better Farms", "Betterest Farms", "Great Farms"])

      within("#filtered_organization_id_in") do
        expect(page).to have_content(market1_seller1.name)
        expect(page).to have_content(market1_seller2.name)
        expect(page).to have_content(market1_seller3.name)
        expect(page).to have_content(market1_seller4.name)
        expect(page).not_to have_content(market2_seller1.name)
        expect(page).not_to have_content(market2_seller2.name)
        expect(page).not_to have_content(market2_seller3.name)
        expect(page).not_to have_content(market2_seller4.name)
      end

      unselect market1.name, from: "q_market_id_in"
      select market2.name, from: "q_market_id_in"
      click_button "Filter"

      seller_rows = Dom::Admin::Financials::VendorPaymentRow.all
      expect(seller_rows.map {|r| r.name.text }).to eq(["Best Farms", "Fruit Farms", "Vegetable Farms"])

      within("#filtered_organization_id_in") do
        expect(page).not_to have_content(market1_seller1.name)
        expect(page).not_to have_content(market1_seller2.name)
        expect(page).not_to have_content(market1_seller3.name)
        expect(page).not_to have_content(market1_seller4.name)
        expect(page).to have_content(market2_seller1.name)
        expect(page).to have_content(market2_seller2.name)
        expect(page).to have_content(market2_seller3.name)
        expect(page).to have_content(market2_seller4.name)
      end
    end

    scenario "filtering by organization" do
      switch_to_subdomain(market1.subdomain)
      sign_in_as market_manager
      visit admin_financials_vendor_payments_path

      seller_rows = Dom::Admin::Financials::VendorPaymentRow.all
      expect(seller_rows.map {|r| r.name.text }).to eq(["Best Farms", "Better Farms", "Betterest Farms", "Fruit Farms", "Great Farms", "Vegetable Farms"])

      select market1_seller1.name, from: "Supplier"
      click_button "Filter"

      seller_rows = Dom::Admin::Financials::VendorPaymentRow.all
      expect(seller_rows.map {|r| r.name.text }).to eq(["Better Farms"])

      unselect market1_seller1.name, from: "Supplier"
      select market1_seller3.name, from: "Supplier"
      click_button "Filter"

      seller_rows = Dom::Admin::Financials::VendorPaymentRow.all
      expect(seller_rows.map {|r| r.name.text }).to eq(["Betterest Farms"])
    end

    scenario "filtering by payment status" do
      switch_to_subdomain(market1.subdomain)
      sign_in_as market_manager
      visit admin_financials_vendor_payments_path

      seller_rows = Dom::Admin::Financials::VendorPaymentRow.all
      expect(seller_rows.map {|r| r.name.text }).to eq(["Best Farms", "Better Farms", "Betterest Farms", "Fruit Farms", "Great Farms", "Vegetable Farms"])

      select "Paid", from: "Payment Status"
      click_button "Filter"

      seller_rows = Dom::Admin::Financials::VendorPaymentRow.all
      expect(seller_rows.map {|r| r.name.text }).to eq(["Betterest Farms", "Fruit Farms", "Great Farms", "Vegetable Farms"])
    end

    scenario "filtering by date" do
      switch_to_subdomain(market1.subdomain)
      sign_in_as market_manager
      visit admin_financials_vendor_payments_path

      seller_rows = Dom::Admin::Financials::VendorPaymentRow.all
      expect(seller_rows.map {|r| r.name.text }).to eq(["Best Farms", "Better Farms", "Betterest Farms", "Fruit Farms", "Great Farms", "Vegetable Farms"])

      fill_in "q_placed_at_date_gteq", with: 50.days.ago(today).strftime("%a, %e %B %Y")

      fill_in "q_placed_at_date_lteq", with: 2.weeks.ago(today).strftime("%a, %e %B %Y")
      click_button "Filter"

      seller_rows = Dom::Admin::Financials::VendorPaymentRow.all
      expect(seller_rows.map {|r| r.name.text }).to eq(["Best Farms", "Better Farms"])

      fill_in "q_placed_at_date_gteq", with: 2.weeks.ago(today).strftime("%a, %e %B %Y")
      fill_in "q_placed_at_date_lteq", with: ""
      click_button "Filter"

      seller_rows = Dom::Admin::Financials::VendorPaymentRow.all
      expect(seller_rows.map {|r| r.name.text }).to eq(["Betterest Farms", "Fruit Farms", "Great Farms", "Vegetable Farms"])
    end

    scenario "searching by order number" do
      switch_to_subdomain(market1.subdomain)
      sign_in_as market_manager
      visit admin_financials_vendor_payments_path

      seller_rows = Dom::Admin::Financials::VendorPaymentRow.all
      expect(seller_rows.map {|r| r.name.text }).to eq(["Best Farms", "Better Farms", "Betterest Farms", "Fruit Farms", "Great Farms", "Vegetable Farms"])

      fill_in "q_order_number_cont", with: market1_order1.order_number
      click_button "Filter"

      seller_rows = Dom::Admin::Financials::VendorPaymentRow.all
      expect(seller_rows.map {|r| r.name.text }).to eq(["Better Farms"])

      fill_in "q_order_number_cont", with: market1_order2.order_number
      click_button "Filter"

      seller_rows = Dom::Admin::Financials::VendorPaymentRow.all
      expect(seller_rows.map {|r| r.name.text }).to eq(["Betterest Farms", "Great Farms"])
    end
  end

  context "admin" do
    let(:user) { create(:user, :admin) }


    scenario "admin can view vendor_payments view" do
      switch_to_subdomain "app"

      sign_in_as(user)
      visit admin_financials_vendor_payments_path

      expect(page).not_to have_select("This is all money that Local Orbit owes to your Sellers.")
    end
  end
end

feature 'Record payments to suppliers', :js  do

  include_context 'the mini market'
  include_context 'second market'

  let!(:order3_item1) { create(:order_item, product: sally_product1, unit_price: 9.99) }
  let!(:order3) { create(:order, placed_at: 4.days.ago, items: [order3_item1], market: second_market, organization: buyer2_organization) }
  let!(:order4_item1) { create(:order_item, product: sally_product2, unit_price: 9.99) }
  let!(:order4) { create(:order, placed_at: 4.days.ago, items: [order4_item1], market: second_market, organization: buyer2_organization) }

  before do
    second_market.managers << mary
    mary.organizations << second_market.organization
    second_market.organizations << seller_organization
    SetOrderItemsStatus.perform(
      user: mary,
      order_item_ids: [order1_item1.id, order2_item1.id, order3_item1.id, order4_item1.id],
      delivery_status: 'delivered'
    )
    switch_to_subdomain mini_market.subdomain
    sign_in_as mary
  end

  it 'displays all sellers to whom a managed market owes payment' do
    visit admin_financials_vendor_payments_path

    expect(page).to have_content('Record Payments to Suppliers')
    expect(page).to have_content("Sally's Staples")
    expect(page).to have_content('2 orders from Mini Market')
    expect(page).to have_content('$13.98')

    expect(page).to have_content('2 orders from Second Market')
    expect(page).to have_content('$19.98')
  end

  it 'allows complete payment of all unpaid orders for seller within a market' do
    visit admin_financials_vendor_payments_path

    first('.pay-all-now').click
    expect(page).to have_content('Cash')
    first('.payment-types').choose('Check')
    first('.check').fill_in('Check #', with: '123')
    first('.record-payment').click_button('Record Payment')
    expect(page).to have_content("Payment of $13.98 recorded for Sally's Staples")
  end

  it 'allows partial payment of some unpaid orders for seller within a market' do
    visit admin_financials_vendor_payments_path

    first('.review-orders').click
    expect(page).to have_content('Hide Orders')
    expect(page).to have_content(order1.order_number)
    expect(first('.line-total')).to have_content('$6.99')
    expect(page).to have_content(order2.order_number)
    first('.payment-order').uncheck('payment_order_ids_')
    expect(first('.total-owed')).to have_content('$6.99')

    first('.pay-selected-now').click
    expect(page).to have_content('Cash')
    first('.payment-types').choose('Check')
    first('.check').fill_in('Check #', with: '123')
    first('.record-payment').click_button('Record Payment')
    expect(page).to have_content("Payment of $6.99 recorded for Sally's Staples")
  end

  it 'uses sticky filter params when scoping orders' do
    visit admin_financials_vendor_payments_path

    expect(page).to have_selector('.vendor-payment', count: 2)
    fill_in('q_placed_at_date_gteq', with: 2.days.ago.strftime("%Y-%m-%d"))
    click_on('Filter')
    # filter works?
    expect(page).to have_selector('.vendor-payment', count: 1)
    # sticky filter works?
    visit admin_financials_vendor_payments_path
    expect(page).to have_selector('.vendor-payment', count: 1)
  end

end
