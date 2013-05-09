LW.Models.Game = Backbone.Model.extend
  initialize: (options) ->
    @set 'pickLength', 12
    @currentLanguage = 'english'
    @set 'match', options.match
    # formedWordArray
    # pickedLettersMask
    # currentLetters
    # foundWords

  emptyForRound: ->
    @set 'formedWordArray', []
    @set 'pickedLettersMask', []
    @set 'currentLetters', []
    @set 'foundWords', []

  saveAndResetMatch: ->
    if @get('match').get('rounds') > 0
      console.log 'resetting match, will save old match here'
      @get('match').reset() 
    else 
      # do nothing

  prepNewMatch: ->
    @populatePickedLettersMask()
    @pickCurrentLetters()

  prepNewRound: ->
    @populatePickedLettersMask()
    @pickCurrentLetters()

  populatePickedLettersMask: ->
    arr = []
    _.times @get('pickLength'), =>
      arr.push(false)

    @set 'pickedLettersMask', arr

  pickCurrentLetters: ->
    alpha = LW.dictionary[@currentLanguage].get('frequencyAlphabet')
    _.times @get('pickLength'), =>
      @get('currentLetters').push(
        alpha[ _.random(0, alpha.length - 1) ]
      )

  resetWordPick: ->
    @set 'formedWordArray', []
    @populatePickedLettersMask()

  inDictionaryAndNotAlreadyChosen: (word) ->
    LW.dictionary[@currentLanguage].has( word ) &&
    !_.contains( @get('foundWords'), word )

  addToFoundWords: ( word )->
    @get('foundWords').push( word )

  recordTotals: ->
    @recordPoints()
    @incrementPoints()
    @incrementRound()

  recordPoints: ->
    pts = @get('foundWords').join('').length
    @get('match').get('score').set 'currentPts', pts

    return pts

  incrementPoints: ->
    @get('match').get('score').set 'pts',
      @get('match').get('score').get('pts') +
      @get('match').get('score').get('currentPts')

  incrementRound: ->
    @get('match').set('rounds', @get('match').get('rounds') + 1)
    @get('match').get('rounds')


LW.Models.Match = Backbone.Model.extend
  initialize: ->
    @set 'rounds', 0
    @set 'score', LW.menuBar.scoreView.model

  scoreRound: (foundWords) ->
    round = new LW.Models.Round()

  reset: ->
    @set 'rounds', 0
    @get('score').set('pts', 0)

LW.Models.Score = Backbone.Model.extend
  initialize: ->
    @set 'pts', 0
    @set 'currentPts', 0

LW.Models.Dictionary = Backbone.Model.extend
  initialize: ->
    @listenTo @, 'sync', @makeAlphabet

  url: ->
    '/game/dict/' + @get('language') + '.json'

  makeAlphabet: ->
    @set 'frequencyAlphabet', []

    for ltr, freq of @get 'alpha'
      for i in [0..freq-1] by 1
        @get('frequencyAlphabet').push(ltr)

  has: (word) ->
    return true if @get('text').indexOf(" " + word + " ") != -1
    return false

  lookUp: (word) ->
    host = "http://services.aonaware.com"
    pathAndParams = "/DictService.asmx/Define?word=" + word

    $.ajax
      url: '/dicts/' + @get('language') + '/lookup/' + word
      success: (data) ->
        console.log data
