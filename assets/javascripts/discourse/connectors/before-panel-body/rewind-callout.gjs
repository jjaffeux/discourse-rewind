import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import icon from "discourse/helpers/d-icon";
import KeyValueStore from "discourse/lib/key-value-store";
import isRewindActive from "discourse/plugins/discourse-rewind/discourse/lib/is-rewind-active";

export default class RewindTab extends Component {
  @service router;

  store = new KeyValueStore("discourse_rewind_" + this.fetchYear);

  get showCallout() {
    return isRewindActive() && !this.dismissed;
  }

  get fetchYear() {
    const currentDate = new Date();
    const currentMonth = currentDate.getMonth();
    const currentYear = currentDate.getFullYear();

    if (currentMonth === 0) {
      return currentYear - 1;
    } else {
      return currentYear;
    }
  }

  get dismissed() {
    return this.store.getObject("_dismissed") ?? false;
  }

  @action
  openRewind() {
    this.store.setObject({ key: "_dismissed", value: true });
    this.router.transitionTo("/my/activity/rewind");
  }

  <template>
    {{#if this.showCallout}}
      <div class="rewind-callout__container">
        <DButton
          @action={{this.openRewind}}
          class="rewind-callout btn-transparent"
        >
          <img
            class="rewind-logo -light"
            src="/plugins/discourse-rewind/images/discourse-rewind-logo.png"
          />
          <img
            class="rewind-logo -dark"
            src="/plugins/discourse-rewind/images/discourse-rewind-logo-dark.png"
          />

          {{icon "arrow-right" class="rewind-callaout__arrow"}}
        </DButton>
      </div>
    {{/if}}
  </template>
}
