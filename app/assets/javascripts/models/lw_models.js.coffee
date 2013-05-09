LW.Models.Game = Backbone.Model.extend
  initialize: ->
    @set 'pickLength', 12
    @currentLanguage = 'english'
    # match
    # formedWordArray
    # pickedLettersMask
    # currentLetters
    # foundWords
    # match

  emptyForRound: ->
    @set 'formedWordArray', []
    @set 'pickedLettersMask', []
    @set 'currentLetters', []
    @set 'foundWords', []

  # makeMatch: ->
  #   @makeNewMatch()

  saveAndDeleteOldMatch: ->
    if @get('match')
      console.log 'will save old match here'
      @set('match', null)
      # user pts = match pts

  makeAndPrepNewMatch: ->
    @set 'match', new LW.Models.Match()
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

  countPoints: ->
    return @get('foundWords').join('').length

  incrementPoints: (points) ->
    console.log @get('match').get('score').get('pts'), points
    @get('match').get('score').set 'pts',
      @get('match').get('score').get('pts') + points


  # startRound: ->
  #   @pickCurrentLetters()
  #   @set 'foundWords', []
  #   @readyForNewWord()
  #   LW.menuBar.timerView.start()

  # endRound: ->
  #   # if we're not starting the first round of the match
  #   if @get('match').get('rounds').length != 0
  #     pts = @get('match').get('score').get('pts')
  #     # pts = pts + 

  #     if @get('match').get('rounds').length >= 10
  #       # display the score and reset the game
  #       @get('match').reset()

  #   @set 'formedWordArray', []
  #   @set 'pickedLettersMask', []
  #   @set 'currentLetters', []
  #   @set 'foundWords', []


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
