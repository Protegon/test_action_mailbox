class AddImapIdentityToTickets < ActiveRecord::Migration[8.1]
  def up
    add_column :tickets, :imap_host, :string
    add_column :tickets, :imap_username, :string

    execute <<~SQL.squish
      UPDATE tickets
      SET imap_host = 'legacy', imap_username = 'legacy'
      WHERE imap_host IS NULL OR imap_username IS NULL
    SQL

    change_column_null :tickets, :imap_host, false
    change_column_null :tickets, :imap_username, false

    remove_index :tickets, [ :imap_folder, :imap_uid ] if index_exists?(:tickets, [ :imap_folder, :imap_uid ])
    add_index :tickets, [ :imap_host, :imap_username, :imap_folder, :imap_uid ], unique: true, name: "index_tickets_on_imap_identity"
  end

  def down
    remove_index :tickets, name: "index_tickets_on_imap_identity" if index_exists?(:tickets, name: "index_tickets_on_imap_identity")
    add_index :tickets, [ :imap_folder, :imap_uid ], unique: true unless index_exists?(:tickets, [ :imap_folder, :imap_uid ])

    remove_column :tickets, :imap_username
    remove_column :tickets, :imap_host
  end
end
