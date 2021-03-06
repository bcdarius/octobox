# frozen_string_literal: true

class SyncLabelWorker
  include Sidekiq::Worker
  sidekiq_options queue: :sync_subjects, unique: :until_and_while_executing

  def perform(payload)
    repository = Repository.find_by_github_id(payload['repository']['id'])
    return if repository.nil?
    subjects = repository.subjects.label(payload['changes']['name']['from'])
    subjects.each do |subject|
      n = subject.notifications.first
      n.try(:update_subject, true)
    end
  end
end
