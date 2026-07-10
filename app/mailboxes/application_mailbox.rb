class ApplicationMailbox < ActionMailbox::Base
  # Emails sent to orders+<company-slug>@inbound.example.com are turned into
  # Orders for the matching Company. See Company#inbound_email_address.
  routing /\Aorders\+/i => :orders
end
