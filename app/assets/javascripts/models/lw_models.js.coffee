LW.Models.Game = Backbone.Model.extend
  initialize: ->
    @set 'dict', new LW.Models.Dictionary({language: 'english'})
    @set 'pickLength', 10

  dict: =>
    @get 'dict'

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


LW.Models.Letter = Backbone.Model.extend


LW.Models.Dictionary = Backbone.Model.extend
  initialize: ->
    @listenTo @, 'sync', @makebAlphabet 

  url: ->
    '/game/dict/' + @get('language') + '.json'

  makebAlphabet: ->
    console.log 'synced'

  makeAlphabet: ->
    @set 'distrib_alpha', []

    for ltr, freq of @get 'alpha'
      for i in [0..freq-1] by 1
        @get('distrib_alpha').push(ltr)
    console.log 'distrib_alpha', @get 'distrib_alpha'

  has: (word) ->
    return true if @get('text').indexOf(" " + word + " ") != -1
    return false
