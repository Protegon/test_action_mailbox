class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :slug
      t.string :contact_email

      t.timestamps
    end
    add_index :companies, :slug, unique: true
  end
end
