class Order < ApplicationRecord
  belongs_to :company

  enum :status, { pending: 0, confirmed: 1, shipped: 2, cancelled: 3 }, default: :pending
  enum :source, { web: 0, email: 1 }, default: :web

  validates :customer_email, presence: true
  validates :item_description, presence: true
  validates :quantity, numericality: { greater_than: 0 }
end
