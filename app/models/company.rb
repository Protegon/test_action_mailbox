class Company < ApplicationRecord
  INBOUND_EMAIL_DOMAIN = "inbound.example.com"

  has_many :orders, dependent: :destroy

  before_validation :generate_slug, on: :create

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  # The address customers/partners can email to place an order for this
  # company. Action Mailbox routes anything sent to "orders+<slug>@..."
  # to OrdersMailbox, which looks the company back up by its slug.
  def inbound_email_address
    "orders+#{slug}@#{INBOUND_EMAIL_DOMAIN}"
  end

  def as_json(options = {})
    super(options).merge("inbound_email_address" => inbound_email_address)
  end

  private

  def generate_slug
    self.slug = name.to_s.parameterize if slug.blank? && name.present?
  end
end
