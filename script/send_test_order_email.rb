#!/usr/bin/env ruby
# Simulates an inbound order email locally, without any real mail server.
#
# Usage:
#   bin/rails runner script/send_test_order_email.rb [company-slug]
#
# Defaults to the first company's slug if none is given.

require "action_mailbox/test_helper"
include ActionMailbox::TestHelper

slug = ARGV.first || Company.first&.slug
company = Company.find_by!(slug: slug)

mail = Mail.new do
  from    "Jane Doe <jane@example.com>"
  to      company.inbound_email_address
  subject "Blue Widget x3"
  body    "Please ship 3 blue widgets to 123 Main St."
end

inbound_email = create_inbound_email_from_source(mail.to_s)
inbound_email.route

puts "InboundEmail ##{inbound_email.id} status: #{inbound_email.reload.status}"
puts "Latest order: #{company.orders.order(:id).last&.attributes}"
