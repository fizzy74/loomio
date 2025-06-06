<script lang="js">
import AppConfig          from '@/shared/services/app_config';
import Records            from '@/shared/services/records';
import Session            from '@/shared/services/session';
import EventBus           from '@/shared/services/event_bus';
import AbilityService     from '@/shared/services/ability_service';
import RecordLoader       from '@/shared/services/record_loader';

export default {
  data() {
    return {
      threads: [],
      loader: {}
    };
  },

  created() {
    return EventBus.$on('signedIn', this.init);
  },

  beforeDestroy() {
    return EventBus.$off('signedIn', this.init);
  },

  mounted() {
    EventBus.$emit('content-title-visible', false);
    EventBus.$emit('currentComponent', {
      titleKey: this.titleKey,
      page: 'threadsPage',
      search: {
        placeholder: this.$t('navbar.search_all_threads')
      }
    });
    this.init();
  },

  watch: {
    '$route.query': 'refresh'
  },

  methods: {
    init() {
      this.loader = new RecordLoader({
        collection: 'discussions',
        path: 'direct',
        params: {
          exclude_types: 'poll group outcome'
        }
      });
      this.loader.fetchRecords();

      this.watchRecords({
        key: 'dashboard',
        collections: ['discussions'],
        query: () => {
          this.threads = Records.discussions.collection.chain().find({groupId: null}).simplesort('lastActivityAt', true).data();
        }
      });
    }
  }
};

</script>

<template lang="pug">
v-main
  v-container.threads-page.max-width-1024.px-0.px-sm-3
    h1.text-h4.my-4(tabindex="-1" v-observe-visibility="{callback: titleVisible}" v-t="'sidebar.invite_only_threads'")
    v-layout.mb-3
      v-spacer
      v-btn.threads-page__new-thread-button(color="primary" to="/d/new" v-t="'sidebar.start_thread'")
      //- v-text-field(clearable solo hide-details :value="$route.query.q" @input="onQueryInput" :placeholder="$t('navbar.search_all_threads')" append-icon="mdi-magnify")

    v-card.mb-3.dashboard-page__loading(v-if='loader.loading && threads.length == 0' aria-hidden='true')
      v-list(two-line)
        loading-content(:lineCount='2' v-for='(item, index) in [1,2,3]' :key='index' )
    div(v-else)
      section.threads-page__loaded
        .threads-page__empty(v-if='threads.length == 0')
          p(v-t="'threads_page.no_invite_only_threads'")
        .threads-page__collections(v-else)
          v-card.mb-3.thread-preview-collection__container
            v-list.thread-previews(two-line)
              thread-preview(v-for="thread in threads", :key="thread.id", :thread="thread")

      .d-flex.align-center.justify-center
        div
          p.text-center.text--secondary(v-t="{path: 'members_panel.loaded_of_total', args: {loaded: threads.length, total: loader.total}}")
          v-btn(v-if="!loader.exhausted" @click="loader.fetchRecords()", :loading="loader.loading", v-t="'common.action.load_more'")
</template>
