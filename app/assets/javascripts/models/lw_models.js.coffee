LW.Models.Game = Backbone.Model.extend
  initialize: ->
    @set 'dict', new LW.Models.Dictionary({language: 'english'})
    @set 'pickLength', 10

  readyForNewWord: ->
    @makeCurrentLettersMask()
    @set 'formedWordArray', []

  makeCurrentLettersMask: ->
    arr = []
    _.times @get('pickLength'), =>
      arr.push(true)

    @set 'currentLettersMask', arr

  pickCurrentLetters: ->
    @set 'currentLetters', []
    alpha = @get('dict').get('alphabet')
    _.times @get('pickLength'), =>
      @get('currentLetters').push(
        alpha[ _.random(0, alpha.length - 1) ]
      )

  startRound: ->
    @pickCurrentLetters()
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
