#!/usr/bin/env ruby
# Pulls messages caught by MailCatcher (http://localhost:1080) and delivers
# them into ActionMailbox, exactly like a production relay ingress would.
# Safe to re-run: ActionMailbox dedupes by Message-ID.
#
# Requires MailCatcher running: bundle exec mailcatcher
#
# Usage:
#   bin/rails runner script/relay_mailcatcher_to_mailbox.rb

require "net/http"
require "json"

messages = JSON.parse(Net::HTTP.get(URI("http://127.0.0.1:1080/messages")))

if messages.empty?
  puts "No messages waiting in MailCatcher (http://localhost:1080)."
  exit
end

messages.each do |message|
  id = message["id"]
  source = Net::HTTP.get(URI("http://127.0.0.1:1080/messages/#{id}.source"))

  inbound_email = ActionMailbox::InboundEmail.create_and_extract_message_id!(source)

  if inbound_email.nil?
    puts "Message ##{id}: already relayed, skipping"
    next
  end

  inbound_email.route
  puts "Message ##{id} -> InboundEmail ##{inbound_email.id} (#{inbound_email.reload.status})"
end
