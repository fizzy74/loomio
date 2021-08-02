import BaseModel  from  '@/shared/record_store/base_model'
import Records  from  '@/shared/services/records'
import {map, parseInt} from 'lodash'
import I18n from '@/i18n'


export default class PollOptionModel extends BaseModel
  @singular: 'pollOption'
  @plural: 'pollOptions'
  @indices: ['pollId']

  defaultValues: ->
    scoreCounts: {}
    voterScores: {}

  relationships: ->
    @belongsTo 'poll'
    @hasMany   'stanceChoices'

  stances: ->
    stanceIds = map @stanceChoices(), 'stanceId'
    Records.stances.find(id: {$in: stanceIds}, latest: true, revokedAt: null)

  beforeRemove: ->
    @stances().each (stance) -> stance.remove()

  optionName: ->
    if @poll().translateOptionName()
      I18n.t('poll_' + @poll().pollType + '_options.' + @name)
    else
      @name

  voterIds: ->
    map Object.keys(@voterScores), parseInt

  voters: ->
    # @recordStore.users.chain().find(id: $in(@voterIds)
    @recordStore.users.find(@voterIds())

  scorePercent: ->
    parseInt(parseFloat(@totalScore) / parseFloat(@poll().totalScore) * 100) || 0
