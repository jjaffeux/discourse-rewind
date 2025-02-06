import DNavigationItem from "discourse/components/d-navigation-item";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";
import isRewindActive from "discourse/plugins/discourse-rewind/discourse/lib/is-rewind-active";

const RewindTab = <template>
  {{#if isRewindActive}}
    <DNavigationItem
      @route="userActivity.rewind"
      @ariaCurrentContext="subNav"
      class="user-nav__activity-rewind"
    >
      {{icon "repeat"}}
      <span>{{i18n "discourse_rewind.title"}}</span>
    </DNavigationItem>
  {{/if}}
</template>;

export default RewindTab;
