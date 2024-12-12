# frozen_string_literal: true

# name: discourse-rewind
# about: TODO
# meta_topic_id: TODO
# version: 0.0.1
# authors: Discourse
# url: TODO
# required_version: 2.7.0

enabled_site_setting :discourse_rewind_enabled

register_svg_icon "repeat"

register_asset "stylesheets/common/index.scss"
register_asset "stylesheets/desktop/index.scss", :desktop
register_asset "stylesheets/mobile/index.scss", :mobile

module ::DiscourseRewind
  PLUGIN_NAME = "discourse-rewind"

  def self.public_asset_path(name)
    File.expand_path(File.join(__dir__, "public", name))
  end
end

require_relative "lib/discourse_rewind/engine"

after_initialize {}
