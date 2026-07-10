class OrdersMailbox < ApplicationMailbox
  before_processing :require_company

  def process
    company.orders.create!(
      customer_name: sender_name,
      customer_email: sender_email,
      item_description: mail.subject.presence || "Order received by email",
      details: body,
      quantity: 1,
      source: :email,
      status: :pending
    )
  end

  private

  def require_company
    bounced! unless company
  end

  def company
    @company ||= Company.find_by(slug: company_slug)
  end

  # Recipients look like "orders+acme-inc@inbound.example.com" — pull the
  # slug out of the plus-addressing so we know which company this is for.
  def company_slug
    recipient = recipients.find { |address| address.match?(/\Aorders\+/i) }
    recipient&.split("+", 2)&.last&.split("@", 2)&.first
  end

  def recipients
    Array(mail.to) + Array(mail.cc) + Array(mail.bcc)
  end

  def sender_email
    mail.from&.first
  end

  def sender_name
    mail[:from]&.addrs&.first&.display_name.presence || sender_email
  end

  def body
    (mail.text_part || mail).decoded.to_s.strip
  rescue StandardError
    ""
  end
end
