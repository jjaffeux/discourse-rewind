# frozen_string_literal: true

module DiscourseRewind
  # Service responsible to fetch a rewind for a username/year.
  #
  # @example
  #  ::DiscourseRewind::Rewind::Fetch.call(
  #    guardian: guardian
  #  )
  #
  class Rewind::Fetch
    include Service::Base

    # @!method self.call(guardian:, params:)
    #   @param [Guardian] guardian
    #   @param [Hash] params
    #   @option params [Integer] :year of the rewind
    #   @option params [Integer] :username of the rewind
    #   @return [Service::Base::Context]

    # order matters, rewinds are displayed in the order they are defined
    REPORTS = [
      DiscourseRewind::Rewind::Action::ReadingTime,
      DiscourseRewind::Rewind::Action::PostingCalendar,
    ].freeze

    CACHE_DURATION = 5.minutes

    model :user
    model :date
    model :reports

    private

    def fetch_user(guardian:)
      User.find_by_username(guardian.user.username)
    end

    def fetch_date(params:)
      Date.new(2024).all_year
    end

    def fetch_reports(date:, user:, guardian:)
      key = "rewind:#{guardian.user.username}:#{2024}"
      reports = Discourse.redis.get(key)

      if Rails.env.development? || !reports
        reports = REPORTS.map { |report| report.call(date:, user:, guardian:) }
        Discourse.redis.setex(key, CACHE_DURATION, MultiJson.dump(reports))
      else
        reports = MultiJson.load(reports, symbolize_keys: true)
      end

      if Rails.env.development?
        reports.each do |report|
          puts "\n--- #{report[:identifier]} ---\n"
          pp report
        end
      end

      reports
    end
  end
end
