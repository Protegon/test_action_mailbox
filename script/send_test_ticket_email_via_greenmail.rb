#!/usr/bin/env ruby
# Sends a test email to GreenMail. The IMAP sync job will later read the
# recipient inbox and create a ticket from this message.
#
# Usage:
#   bin/rails runner script/send_test_ticket_email_via_greenmail.rb

require "net/smtp"

smtp_host = ENV.fetch("SMTP_HOST", "localhost")
smtp_port = ENV.fetch("SMTP_PORT", "3025").to_i
to = ENV.fetch("SMTP_TO", "support@mail.example.com")

mail = Mail.new do
  from    "Cliente Teste <cliente@example.com>"
  to      to
  subject "Chamado de teste via GreenMail"
  body    "Conteudo do chamado criado para validar o fluxo SMTP + IMAP."
end

Net::SMTP.start(smtp_host, smtp_port) do |smtp|
  smtp.send_message(mail.to_s, mail.from.first, mail.to)
end

puts "Delivered to GreenMail SMTP at #{smtp_host}:#{smtp_port} (to: #{to})"
