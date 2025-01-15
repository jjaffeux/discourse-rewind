# frozen_string_literal: true

# For a most user / received reactions cards
module DiscourseRewind
  class Rewind::Action::Reactions < Rewind::Action::BaseReport
    FakeData = {
      data: {
        post_received_reactions: {
          open_mouth: 2,
          cat: 32,
          dog: 34,
          heart: 45,
          grinning: 82,
        },
        post_used_reactions: {
          open_mouth: 2,
          cat: 32,
          dog: 34,
          heart: 45,
          grinning: 82,
        },
        chat_used_reactions: {
          open_mouth: 2,
          cat: 32,
          dog: 34,
          heart: 45,
          grinning: 82,
        },
        chat_received_reactions: {
          open_mouth: 2,
          cat: 32,
          dog: 34,
          heart: 45,
          grinning: 82,
        },
      },
      identifier: "reactions",
    }

    def call
      return FakeData if Rails.env.development?

      data = {}
      if defined?(DiscourseReactions::Reaction)
        # This is missing heart reactions (default like)
        data[:post_used_reactions] = sort_and_limit(
          DiscourseReactions::Reaction
            .by_user(user)
            .where(created_at: date)
            .group(:reaction_value)
            .count,
        )

        data[:post_received_reactions] = sort_and_limit(
          DiscourseReactions::Reaction
            .includes(:post)
            .where(posts: { user_id: user.id })
            .where(created_at: date)
            .group(:reaction_value)
            .count,
        )
      end

      if SiteSetting.chat_enabled
        data[:chat_used_reactions] = sort_and_limit(
          Chat::MessageReaction.where(user: user).where(created_at: date).group(:emoji).count,
        )

        data[:chat_received_reactions] = sort_and_limit(
          Chat::MessageReaction
            .includes(:chat_message)
            .where(chat_message: { user_id: user.id })
            .where(created_at: date)
            .group(:emoji)
            .count,
        )
      end

      { data:, identifier: "reactions" }
    end

    def enabled?
      SiteSetting.discourse_reactions_enabled || SiteSetting.chat_enabled
    end

    def sort_and_limit(reactions)
      reactions.sort_by { |_, v| -v }.first(5).reverse.to_h
    end
  end
end
