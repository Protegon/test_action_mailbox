#!/usr/bin/env ruby
# Simulates a customer emailing in an order by sending real SMTP traffic to a
# local Mailserver instance, instead of calling ActionMailbox directly. This
# exercises the same path a real inbound email takes once relayed into the app
# (see script/relay_mailserver_to_mailbox.rb).
#
# Requires Mailserver running: docker-compose up -d mailserver
#
# Usage:
#   bin/rails runner script/send_test_email_via_mailserver.rb [company-slug]

require "net/smtp"

slug = ARGV.first || Company.first&.slug
company = Company.find_by!(slug: slug)

mail = Mail.new do
  from    "Jane Doe <jane@example.com>"
  to      company.inbound_email_address
  subject "Mailserver test"
  body    "Please ship 3 blue widgets to 123 Main St."
end

Net::SMTP.start("localhost", 25, "localhost.localdomain") do |smtp|
  smtp.send_message(mail.to_s, mail.from.first, mail.to)
end

puts "Delivered to Mailserver (to: #{mail.to.first})"
puts "Run `bin/rails runner script/relay_mailserver_to_mailbox.rb` to hand it to ActionMailbox."
