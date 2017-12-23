module.exports =
  submitForm: (scope, model, options = {}) ->
    # fetch draft from server and listen for changes to it
    if options.drafts and model.isNew() and AbilityService.isLoggedIn()
      model.fetchAndRestoreDraft()
      scope.$watch model.draftFields, model.planDraftFetch, true

    submitFn  = options.submitFn  or model.save
    confirmFn = options.confirmFn or (-> false)
    (prepareArgs) ->
      return if scope.isDisabled
      prepare(scope, model, options, prepareArgs)
      if confirm(confirmFn(model))
        submitFn(model).then(
          success(scope, model, options),
          failure(scope, model, options),
        ).finally(
          cleanup(scope, model, options)
        )
      else
        cleanup(scope, model, options)

  upload: (scope, model, options = {}) ->
    (files) ->
      if _.any files
        prepare(scope, model, options)
        submitFn(files[0], options.uploadKind).then(
          success(scope, model, options),
          failure(scope, model, options)
        ).finally(
          cleanup(scope, model, options)
        )

prepare = (scope, model, options, prepareArgs) ->
  FlashService.loading(options.loadingMessage)
  options.prepareFn(prepareArgs) if typeof options.prepareFn is 'function'
  scope.$emit 'processing'       if typeof scope.$emit       is 'function'
  scope.isDisabled = true
  model.setErrors()

confirm = (confirmMessage) ->
  if confirmMessage and typeof window.confirm == 'function'
    window.confirm(confirmMessage)
  else
    true

success = (scope, model, options) ->
  (response) ->
    FlashService.dismiss()
    if options.flashSuccess?
      flashKey     = if typeof options.flashSuccess is 'function' then options.flashSuccess() else options.flashSuccess
      FlashService.success flashKey, calculateFlashOptions(options.flashOptions)
    scope.$close()                                          if !options.skipClose? and typeof scope.$close is 'function'
    model.cancelDraftFetch()                                if typeof model.cancelDraftFetch is 'function'
    options.successCallback(response)                       if typeof options.successCallback is 'function'

failure = (scope, model, options) ->
  (response) ->
    FlashService.dismiss()
    options.failureCallback(response)                       if typeof options.failureCallback is 'function'
    model.setErrors response.data.errors                    if _.contains([401,422], response.status)
    scope.$emit errorTypes[response.status] or 'unknownError',
      model: model
      response: response

cleanup = (scope, model, options = {}) ->
  ->
    options.cleanupFn(scope, model) if typeof options.cleanupFn is 'function'
    scope.$emit 'doneProcessing'    if typeof scope.$emit       is 'function'
    scope.isDisabled = false

errorTypes =
  400: 'badRequest'
  401: 'unauthorizedRequest'
  403: 'forbiddenRequest'
  404: 'resourceNotFound'
  422: 'unprocessableEntity'
  500: 'internalServerError'
