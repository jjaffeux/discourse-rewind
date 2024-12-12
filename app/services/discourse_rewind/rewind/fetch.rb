# frozen_string_literal: true

module DiscourseRewind
  # Service responsible to fetch a rewind for a username/year.
  #
  # @example
  #  ::DiscourseRewind::Rewind::Fetch.call(
  #    guardian: guardian,
  #    params: {
  #      username: "falco",
  #      year: 2024,
  #    }
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

    # Do we need a custom order?
    available_reports = DiscourseRewind::Rewind::Action::Base.descendants

    CACHE_DURATION = 5.minutes

    params do
      attribute :year, :integer
      attribute :username, :string

      validates :year, presence: true
      validates :username, presence: true
    end

    model :user
    model :date
    model :reports

    private

    def fetch_user(params:)
      User.find_by_username(params.username)
    end

    def fetch_date(params:)
      Date.new(params.year).all_year
    end

    def fetch_reports(params:, date:, user:, guardian:)
      key = "rewind:#{params.username}:#{params.year}"
      reports = Discourse.redis.get(key)

      if Rails.env.development? || !reports
        reports =
          available_reports
            .filter { _1.enabled? }
            .map { |report| report.call(params:, date:, user:, guardian:) }
        Discourse.redis.setex(key, CACHE_DURATION, MultiJson.dump(reports))
      else
        reports = MultiJson.load(reports, symbolize_keys: true)
      end

      reports
    end
  end
end
