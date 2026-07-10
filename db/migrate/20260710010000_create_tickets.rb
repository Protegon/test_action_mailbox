class CreateTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :tickets do |t|
      t.string :email_from, null: false
      t.string :title, null: false
      t.text :content, null: false
      t.string :imap_folder, null: false, default: "INBOX"
      t.integer :imap_uid, null: false
      t.string :message_id

      t.timestamps
    end

    add_index :tickets, [ :imap_folder, :imap_uid ], unique: true
    add_index :tickets, :email_from
  end
end
