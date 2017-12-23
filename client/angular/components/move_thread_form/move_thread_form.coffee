Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'

{ submitForm } = require 'angular/helpers/form.coffee'

angular.module('loomioApp').factory 'MoveThreadForm', ($translate) ->
  templateUrl: 'generated/components/move_thread_form/move_thread_form.html'
  controller: ($scope, discussion) ->
    $scope.discussion = discussion.clone()

    $scope.availableGroups = ->
      _.filter Session.user().groups(), (group) ->
        group.id != discussion.groupId

    $scope.submit = submitForm $scope, $scope.discussion,
      submitFn: $scope.discussion.move
      flashSuccess: 'move_thread_form.messages.success'
      flashOptions:
        name: -> $scope.discussion.group().name

    $scope.updateTarget = ->
      $scope.targetGroup = Records.groups.find($scope.discussion.groupId)
    $scope.updateTarget()

    $scope.moveThread = ->
      if $scope.discussion.private and $scope.targetGroup.privacyIsOpen()
        $scope.submit() if confirm($translate.instant('move_thread_form.confirm_change_to_private_thread', groupName: $scope.targetGroup.name))
      else
        $scope.submit()
