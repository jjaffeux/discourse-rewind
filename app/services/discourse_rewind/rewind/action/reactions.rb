# frozen_string_literal: true

# For a most user / received reactions cards
module DiscourseRewind
  class Rewind::Action::Reactions < Action::Base
    def call
      post_used_reactions = {}
      post_received_reactions = {}
      chat_used_reactions = {}
      chat_received_reactions = {}

      if defined?(DiscourseReactions::Reaction)
        # This is missing heart reactions (default like)
        post_used_reactions =
          DiscourseReactions::Reaction
            .by_user(user)
            .where(created_at: date)
            .group(:reaction_value)
            .count

        post_received_reactions =
          DiscourseReactions::Reaction
            .includes(:post)
            .where(posts: { user_id: user.id })
            .where(created_at: date)
            .group(:reaction_value)
            .count
      end

      if SiteSetting.chat_enabled
        chat_used_reactions =
          Chat::MessageReaction.where(user: user).where(created_at: date).group(:emoji).count

        chat_received_reactions =
          Chat::MessageReaction
            .includes(:chat_message)
            .where(chat_message: { user_id: user.id })
            .where(created_at: date)
            .group(:emoji)
            .count
      end

      {
        data: {
          post_used_reactions: sort_and_limit(post_used_reactions),
          post_received_reactions: sort_and_limit(post_received_reactions),
          chat_used_reactions: sort_and_limit(chat_used_reactions),
          chat_received_reactions: sort_and_limit(chat_received_reactions),
        },
        identifier: "reactions",
      }
    end

    def enabled?
      SiteSetting.discourse_reaction_enabled || SiteSetting.chat_enabled
    end

    def sort_and_limit(reactions)
      reactions.sort_by { |_, v| -v }.first(6).to_h
    end
  end
end
