class MarketAddress < ActiveRecord::Base
  audited allow_mass_assignment: true
  include SoftDelete

  belongs_to :market, inverse_of: :addresses

  validates :name, presence: true, uniqueness: {scope: [:market_id, :deleted_at]}
  validates :address, :city, :state, :zip, :market, presence: true

  acts_as_geocodable address: {street: :address, locality: :city, region: :state, postal_code: :zip}

  def self.alphabetical_by_name
    order(name: :asc)
  end

end
