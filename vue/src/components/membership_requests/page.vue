<script lang="coffee">
import AppConfig      from '@/shared/services/app_config'
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import Flash   from '@/shared/services/flash'
import { isEmpty }    from 'lodash'
import WatchRecords from '@/mixins/watch_records'

export default
  mixins: [WatchRecords]

  data: ->
    group: null
    pendingRequests: []
    previousRequests: []

  created: ->
    EventBus.$emit 'currentComponent', { page: 'membershipRequestsPage'}
    @init()

  methods:
    init: ->
      Records.groups.findOrFetchById(@$route.params.key).then (group) =>
        if AbilityService.canManageMembershipRequests(group)
          @group = group
          Records.membershipRequests.fetchPendingByGroup(group.key, per: 100)
          Records.membershipRequests.fetchPreviousByGroup(group.key, per: 100)
          @watchRecords
            collections: ['membershipRequests']
            query: (store) =>
              @pendingRequests = @group.pendingMembershipRequests()
              @previousRequests = @group.previousMembershipRequests()
        else
          EventBus.$emit 'pageError', {status: 403}
      , (error) ->
          EventBus.$emit 'pageError', {status: 403}

    approve: (membershipRequest) ->
      Records.membershipRequests.approve(membershipRequest).then =>
        @init()
        Flash.success "membership_requests_page.messages.request_approved_success"

    ignore: (membershipRequest) ->
      Records.membershipRequests.ignore(membershipRequest).then =>
        @init()
        Flash.success "membership_requests_page.messages.request_ignored_success"

  computed:
    isEmptyGroup: -> isEmpty @group

</script>

<template lang="pug">
loading(:until="group")
  group-cover-image(:group="group")
  v-container.membership-requests-page
    h1.headline(v-t="'membership_requests_page.heading'")
    v-card
      v-card-text
        v-list.membership-requests-page__pending-requests(subheader)
          v-subheader.membership-requests-page__no-pending-requests(v-if='pendingRequests.length == 0' v-t="'membership_requests_page.no_pending_requests'")
          v-list-item.membership-requests-page__pending-request(v-for='request in pendingRequests' :key='request.id' avatar)
            v-list-item-avatar
              user-avatar(:user='request.actor()', size='medium')
            v-list-item-content
              v-list-item-title.membership-requests-page__pending-request-name {{request.actor().name}} ({{request.email}})
              v-list-item-subtitle.membership-requests-page__pending-request-introduction
                span {{request.introduction}}
                time-ago(:date='request.createdAt')
            v-list-item-action
              //- , v-t="'membership_requests_page.ignore'"
              //- , v-t="'membership_requests_page.approve'"
              v-btn.membership-requests-page__approve(text icon @click='approve(request)')
                v-icon mdi-check
            v-list-item-action
              v-btn.membership-requests-page__ignore(text icon @click='ignore(request)')
                v-icon mdi-close

        v-list.membership-requests-page__previous-requests(subheader three-line)
          v-subheader(v-if='previousRequests.length' v-t="'membership_requests_page.previous_requests'")
          v-subheader.membership-requests-page__no-previous-requests(v-if='previousRequests.length == 0' v-t="'membership_requests_page.no_previous_requests'")
          v-list-item.membership-requests-page__previous-request(v-for='request in previousRequests' :key='request.id' avatar)
            v-list-item-avatar
              user-avatar(:user='request.actor()', size='medium')
            v-list-item-content
              v-list-item-title.membership-requests-page__previous-request-name {{request.actor().name}} {{request.email}}
              v-list-item-subtitle.membership-requests-page__previous-request-response
                span(v-t="{ path: 'membership_requests_page.previous_request_response', args: { response: request.formattedResponse(), responder: request.responder().name } }")
                span ·
                time-ago(:date='request.respondedAt')
                .membership-requests-page__previous-request-introduction {{request.introduction}}

</template>
