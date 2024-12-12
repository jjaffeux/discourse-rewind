# frozen_string_literal: true

module ::DiscourseRewind
  class RewindsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    def show
      DiscourseRewind::Rewind::Fetch.call(service_params) do
        on_success do |reports:|
          @reports = reports
          render json: MultiJson.dump(reports), status: 200
        end
      end
    end
  end
end
