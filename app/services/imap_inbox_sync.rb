require "mail"
require "net/imap"

class ImapInboxSync
  REQUIRED_ENV = %w[IMAP_HOST IMAP_USERNAME IMAP_PASSWORD].freeze

  def call
    validate_configuration!

    imap = Net::IMAP.new(host, port: port, ssl: ssl?)
    imap.login(username, password)
    imap.select(folder)

    deletable_uids = []

    imap.uid_search([ "ALL" ]).each do |uid|
      if Ticket.exists?(imap_identity.merge(imap_folder: folder, imap_uid: uid))
        deletable_uids << uid
        next
      end

      deletable_uids << uid if create_ticket_from(imap, uid)
    end

    delete_messages(imap, deletable_uids)
  ensure
    imap&.logout unless imap&.disconnected?
    imap&.disconnect unless imap&.disconnected?
  end

  private

  def create_ticket_from(imap, uid)
    response = imap.uid_fetch(uid, [ "RFC822" ]).first
    return unless response

    mail = Mail.read_from_string(response.attr["RFC822"])

    Ticket.create!(
      email_from: from_address(mail),
      title: mail.subject.presence || "Sem assunto",
      content: body(mail),
      imap_host: host,
      imap_username: username,
      imap_folder: folder,
      imap_uid: uid,
      message_id: mail.message_id
    )

    true
  rescue ActiveRecord::RecordNotUnique
    false
  end

  def delete_messages(imap, uids)
    return if uids.empty?

    imap.uid_store(uids, "+FLAGS", [ Net::IMAP::DELETED ])
    imap.expunge
  end

  def validate_configuration!
    missing = REQUIRED_ENV.select { |key| ENV[key].blank? }
    return if missing.empty?

    raise ArgumentError, "Missing IMAP configuration: #{missing.join(', ')}"
  end

  def imap_identity
    { imap_host: host, imap_username: username }
  end

  def from_address(mail)
    mail.from&.first.presence || "unknown@example.com"
  end

  def body(mail)
    if mail.text_part
      decoded_body(mail.text_part)
    elsif mail.html_part
      sanitize_html(decoded_body(mail.html_part))
    elsif mail.mime_type == "text/html"
      sanitize_html(decoded_body(mail))
    else
      decoded_body(mail)
    end
  end

  def decoded_body(part)
    part.decoded.to_s.strip
  rescue StandardError
    ""
  end

  def sanitize_html(html)
    ActionView::Base.full_sanitizer.sanitize(html).to_s.squish
  rescue StandardError
    ""
  end

  def host
    ENV.fetch("IMAP_HOST")
  end

  def port
    ENV.fetch("IMAP_PORT", "993").to_i
  end

  def ssl?
    ActiveModel::Type::Boolean.new.cast(ENV.fetch("IMAP_SSL", "true"))
  end

  def username
    ENV.fetch("IMAP_USERNAME")
  end

  def password
    ENV.fetch("IMAP_PASSWORD")
  end

  def folder
    ENV.fetch("IMAP_FOLDER", "INBOX")
  end
end
