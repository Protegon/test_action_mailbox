#!/usr/bin/env ruby
# Reads messages delivered to the "orders" mailbox by the local Mailserver
# container (docker-compose.yaml) and hands them to ActionMailbox, exactly
# like a production relay ingress would.
#
# Mail lands directly on disk in Maildir format via the bind-mounted
# ./docker-data/dms/mail-data volume, so no SMTP/IMAP round-trip is needed to
# read it back out.
#
# Safe to re-run: only unprocessed ("new") messages are relayed, and
# ActionMailbox also dedupes by Message-ID.
#
# Requires Mailserver running: docker-compose up -d mailserver
#
# Usage:
#   bin/rails runner script/relay_mailserver_to_mailbox.rb

require "fileutils"

maildir = Rails.root.join("docker-data", "dms", "mail-data", "mail.example.com", "orders")
new_dir = maildir.join("new")
cur_dir = maildir.join("cur")

filenames = Dir.children(new_dir).sort

if filenames.empty?
  puts "No messages waiting in Mailserver (#{new_dir})."
  exit
end

filenames.each do |filename|
  path = new_dir.join(filename)
  source = File.read(path)

  inbound_email = ActionMailbox::InboundEmail.create_and_extract_message_id!(source)

  if inbound_email.nil?
    puts "#{filename}: already relayed, skipping"
  else
    inbound_email.route
    puts "#{filename} -> InboundEmail ##{inbound_email.id} (#{inbound_email.reload.status})"
  end

  # Move it into cur/ marked Seen, mirroring what an IMAP client would do
  # once it has consumed a message, so re-running the script won't re-relay it.
  FileUtils.mv(path, cur_dir.join("#{filename}:2,S"))
end
