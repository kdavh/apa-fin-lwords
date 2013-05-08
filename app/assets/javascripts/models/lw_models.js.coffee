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
    alpha = @get('dict').get('alphabet')
    _.times @get('pickLength'), =>
      @get('currentLetters').push(
        alpha[ _.random(0, alpha.length - 1) ]
      )

  startRound: ->
    @pickCurrentLetters()
    @set 'foundWords', []
    @readyForNewWord()
    LW.Store.menuBar.timerView.start()


LW.Models.Letter = Backbone.Model.extend


LW.Models.Dictionary = Backbone.Model.extend
  url: ->
    '/game/dict/' + @get('language') + '.json'

  makeAlphabet: ->
    @attributes.alphabet = []

    for i in [97..122] by 1
      @attributes.alphabet.push String.fromCharCode(i)

  has: (word) ->
    return true if @get('text').indexOf(" " + word + " ") != -1
    return false
