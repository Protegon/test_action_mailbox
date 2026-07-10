class Ticket < ApplicationRecord
  validates :email_from, :title, :content, :imap_host, :imap_username, :imap_folder, :imap_uid, presence: true
end
