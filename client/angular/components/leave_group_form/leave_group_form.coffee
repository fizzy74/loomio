Session        = require 'shared/services/session.coffee'
AbilityService = require 'shared/services/ability_service.coffee'

{ submitForm } = require 'angular/helpers/form.coffee'

angular.module('loomioApp').factory 'LeaveGroupForm', ($rootScope, $location) ->
  templateUrl: 'generated/components/leave_group_form/leave_group_form.html'
  controller: ($scope, group) ->
    $scope.group = group
    $scope.membership = $scope.group.membershipFor(Session.user())

    $scope.submit = submitForm $scope, $scope.group,
      submitFn: $scope.membership.destroy
      flashSuccess: 'group_page.messages.leave_group_success'
      successCallback: ->
        $rootScope.$broadcast 'currentUserMembershipsLoaded'
        $location.path '/dashboard'

    $scope.canLeaveGroup = ->
      AbilityService.canRemoveMembership($scope.membership)
