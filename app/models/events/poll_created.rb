class Events::PollCreated < Event
  include Events::LiveUpdate
  include Events::Notify::Mentions
  include Events::Notify::ThirdParty

  def self.publish!(poll, actor)
    super poll,
          user: actor,
          parent: poll.parent_event,
          discussion: poll.discussion,
          pinned: true
  end
end
