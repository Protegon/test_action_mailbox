#!/usr/bin/env ruby
# Simulates a customer emailing in an order by sending real SMTP traffic to a
# local MailCatcher instance, instead of calling ActionMailbox directly. This
# exercises the same path a real inbound email takes once relayed into the app
# (see script/relay_mailcatcher_to_mailbox.rb).
#
# Requires MailCatcher running: bundle exec mailcatcher
#
# Usage:
#   bin/rails runner script/send_test_email_via_mailcatcher.rb [company-slug]

require "net/smtp"

slug = ARGV.first || Company.first&.slug
company = Company.find_by!(slug: slug)

mail = Mail.new do
  from    "Jane Doe <jane@example.com>"
  to      company.inbound_email_address
  subject "Blue Widget x3"
  body    "Please ship 3 blue widgets to 123 Main St."
end

Net::SMTP.start("localhost", 1025) do |smtp|
  smtp.send_message(mail.to_s, mail.from.first, mail.to)
end

puts "Delivered to MailCatcher inbox: http://localhost:1080 (to: #{mail.to.first})"
puts "Run `bin/rails runner script/relay_mailcatcher_to_mailbox.rb` to hand it to ActionMailbox."
