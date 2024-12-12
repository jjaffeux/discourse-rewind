import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class Rewind extends Component {
  @tracked rewind = [];

  @action
  async loadRewind() {
    try {
      this.rewind = await ajax("/rewinds");
    } catch (e) {
      popupAjaxError(e);
    }
  }

  <template>
    <div class="rewind" {{didInsert this.loadRewind}}>
      {{#each this.rewind as |report|}}
        <p>{{report.identifier}}</p>
      {{/each}}
    </div>
  </template>
}
