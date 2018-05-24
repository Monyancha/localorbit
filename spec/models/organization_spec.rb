require "spec_helper"

describe Organization do

  describe "validates" do
    describe "name" do
      it "is required" do
        org = Organization.new
        expect(org).to_not be_valid
        expect(org).to have(1).error_on(:name)
      end

      it "is at most 255 characters long" do
        org = Organization.new(name: "a" * 256)
        expect(org).to_not be_valid
        expect(org).to have(1).error_on(:name)
      end
    end
  end

  describe "Scopes:" do
    describe "#selling" do
      let!(:seller) { create(:organization, :seller) }
      let!(:buyer) { create(:organization, :buyer) }

      it "only returns organizations that can sell" do
        result = Organization.selling
        expect(result.count).to eql(1)
        expect(result.first).to eql(seller)
      end
    end
  end

  describe "#shipping_location" do
    let(:org) { create(:organization) }

    it "returns nil if we have no locations" do
      expect(org.shipping_location).to be_nil
    end

    it "returns the location marked default_shipping" do
      loc = create(:location, organization: org, default_shipping: true)
      expect(org.shipping_location).to eq(loc)
    end

    it "does not return a deleted location" do
      loc = create(:location, organization: org, default_shipping: true, deleted_at: 1.minute.ago)
      expect(org.shipping_location).to be_nil
    end

    it "returns the right location" do
      create(:location, organization: org, default_shipping: true, deleted_at: 1.minute.ago)
      loc = create(:location, organization: org, default_shipping: true)
      expect(org.shipping_location).to eq(loc)
    end
  end

  context "factory" do
    it "has a location" do
      organization = create(:organization, :single_location)

      expect(organization.locations.count).to eq(1)
    end
  end

  describe "#can_cross_sell?" do
    context "as a buyer" do
      it "returns false" do
        organization = build(:organization, :buyer)
        expect(organization.can_cross_sell?).to eq(false)
      end
    end

    context "as a seller" do
      let!(:market) { create(:market, allow_cross_sell: true) }
      let!(:seller) { create(:organization, :seller, markets: [market]) }

      it "returns false if none of the markets allow cross sell." do
        market.update! allow_cross_sell: false
        expect(seller.can_cross_sell?).to eq(false)
      end

      it "returns true if a market allows cross selling" do
        expect(seller.can_cross_sell?).to eq(true)
      end
    end
  end

  describe "#primary_payment_provider" do
    let(:provider) { 'the payment provider' }
    let!(:market) {create(:market, payment_provider: provider)}
    let!(:organization) { create(:organization, markets: [market]) }

    it "returns the payment provider of the first market" do
      expect(organization.primary_payment_provider).to eq provider
    end

    describe "when payment provider on Market is nil" do
      it "returns nil" do
        market.update(payment_provider: nil)
        expect(organization.primary_payment_provider).to be nil
      end
    end

    describe "when there's more than one market" do
      it "returns payment provider of first market" do
        organization.markets << create(:market, payment_provider: "other provider")
        expect(organization.primary_payment_provider).to eq provider
      end
    end

    describe "when there's NO market" do
      it "returns nil" do
        organization.markets.clear
        expect(organization.primary_payment_provider).to be nil
      end
    end


  end
end
