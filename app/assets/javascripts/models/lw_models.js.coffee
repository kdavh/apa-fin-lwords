LW.Models.Game = Backbone.Model.extend
  initialize: ->
    @set 'dict', new LW.Models.Dictionary({language: 'english'})
    @set 'pickLength', 10
    @resetMatch()
    # match
    # formedWordArray
    # pickedLettersMask
    # currentLetters
    # foundWords
    # match
  resetMatch: ->
    @set 'match', new LW.Models.Match()

  readyForNewWord: ->
    @makePickedLettersMask()
    @set 'formedWordArray', []

  makePickedLettersMask: ->
    arr = []
    _.times @get('pickLength'), =>
      arr.push(false)

    @set 'pickedLettersMask', arr

  pickCurrentLetters: ->
    @set 'currentLetters', []
    alpha = @get('dict').get('distrib_alpha')
    _.times @get('pickLength'), =>
      @get('currentLetters').push(
        alpha[ _.random(0, alpha.length - 1) ]
      )

  startRound: ->
    @pickCurrentLetters()
    @set 'foundWords', []
    @readyForNewWord()
    LW.Store.menuBar.timerView.start()

  endRound: ->
    console.log @get 'formedWordArray'
    # if we're not starting the first round of the match
    if !!@get('formedWordArray') != false
      @get('match').scoreRound(@get('foundWords'))
      if @get('match').get('rounds').length >= 10
        console.log ""
        # display the score and reset the game
    @set 'formedWordArray', []
    @set 'pickedLettersMask', []
    @set 'currentLetters', []
    @set 'foundWords', []


LW.Models.Match = Backbone.Model.extend
  initialize: ->
    @set 'rounds', []
    @set 'score', LW.Store.menuBar.scoreView.model

  scoreRound: (foundWords) ->
    round = new LW.Models.Round()

LW.Models.Score = Backbone.Model.extend
  initialize: ->
    @set 'pts', 0

LW.Models.Round = Backbone.Model.extend

LW.Models.Dictionary = Backbone.Model.extend
  initialize: ->
    @listenTo @, 'sync', @makebAlphabet 

  url: ->
    '/game/dict/' + @get('language') + '.json'

  makeAlphabet: ->
    @set 'distrib_alpha', []

    for ltr, freq of @get 'alpha'
      for i in [0..freq-1] by 1
        @get('distrib_alpha').push(ltr)

  has: (word) ->
    return true if @get('text').indexOf(" " + word + " ") != -1
    return false
