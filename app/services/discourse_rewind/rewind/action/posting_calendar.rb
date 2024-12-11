# frozen_string_literal: true

# For a GitHub like calendar
# https://docs.github.com/assets/cb-35216/mw-1440/images/help/profile/contributions-graph.webp
module DiscourseRewind
  class Rewind::Action::PostingCalendar < Service::ActionBase
    option :params
    option :guardian

    delegate :username, :year, to: :params, private: true

    def call
      user = User.find_by_username(username)

      calendar =
        Post
          .where(user: user)
          .where(created_at: Date.new(year).all_year)
          .select("DATE(created_at) as date, count(*) as count")
          .group("DATE(created_at)")
          .order("DATE(created_at)")
          .map { |post| { date: post.date, count: post.count } }

      { data: calendar, identifier: "posting-calendar" }
    end
  end
end
