# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

acme = Company.find_or_create_by!(slug: "acme-inc") do |company|
  company.name = "Acme Inc"
  company.contact_email = "hello@acme.test"
end

acme.orders.find_or_create_by!(item_description: "Blue Widget") do |order|
  order.customer_name = "Jane Doe"
  order.customer_email = "jane@example.com"
  order.quantity = 2
  order.total = 19.98
  order.source = :web
end

puts "Seeded #{Company.count} company(ies) and #{Order.count} order(s)."
puts "Send email to #{acme.inbound_email_address} to create an order for #{acme.name} by email."
