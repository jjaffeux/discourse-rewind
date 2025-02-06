import Component from "@glimmer/component";
import { concat } from "@ember/helper";
import { get } from "@ember/object";
import { htmlSafe } from "@ember/template";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";

export default class BestPosts extends Component {
  rank(idx) {
    return idx + 1;
  }

  <template>
    {{#if @report.data.length}}
      <div class="rewind-report-page -best-posts">
        <h2 class="rewind-report-title">{{i18n
            "discourse_rewind.reports.best_posts.title"
            count=@report.data.length
          }}</h2>
        <div class="rewind-report-container">
          {{#each @report.data as |post idx|}}
            <div class={{concat "rewind-card" " rank-" (this.rank idx)}}>
              <span class="best-posts -rank"></span>
              <span class="best-posts -rank"></span>
              <div class="best-posts__post">{{htmlSafe (get post "5")}}</div>
              <div class="best-posts__metadata">
                <span class="best-posts__likes">
                  {{icon "heart"}}{{htmlSafe (get post "2")}}</span>
                <span class="best-posts__replies">
                  {{icon "comment"}}{{htmlSafe (get post "3")}}</span>
                <a href="/t/{{get post '1'}}/{{get post '0'}}">{{i18n
                    "discourse_rewind.reports.best_posts.view_post"
                  }}</a>
              </div>
            </div>
          {{/each}}
        </div>
      </div>
    {{/if}}
  </template>
}
