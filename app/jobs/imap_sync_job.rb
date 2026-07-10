class ImapSyncJob < ApplicationJob
  queue_as :default

  def perform
    ImapInboxSync.new.call
  end
end
