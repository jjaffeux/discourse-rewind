# frozen_string_literal: true

module DiscourseRewind
  class Rewind::Action::Base < Service::ActionBase
    option :user
    option :date

    def call
      raise NotImplementedError
    end

    def enabled?
      true
    end
  end
end
