class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :company, null: false, foreign_key: true
      t.string :customer_name
      t.string :customer_email
      t.string :item_description
      t.integer :quantity, default: 1, null: false
      t.decimal :total, precision: 10, scale: 2
      t.integer :status, default: 0, null: false
      t.integer :source, default: 0, null: false
      t.text :details

      t.timestamps
    end
  end
end
