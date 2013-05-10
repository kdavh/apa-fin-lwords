LW.Models.Game = Backbone.Model.extend
  initialize: (options) ->
    @set 'pickLength', 12
    @currentLanguage = 'english'
    @translateToLanguage = 'spanish'
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
    @showLoadingStatus()
    @makeRequest(word)

  showLoadingStatus: ->
    $('#definition-bar-label').html('Loading definition...')

  hideLoadingStatus: ->
    $('#definition-bar-label').html('')

  makeRequest: (word) ->
    url = @constructUrl(word)

    $.getJSON( url, { timeout: 10000 } )
      .done( @handleTranslation.bind(this) )
      .always( @hideLoadingStatus.bind(this) )

  constructUrl: (word) ->
    lang1 = LW.dictionary.langHash[LW.gameBoard.model.currentLanguage]
    lang2 = LW.dictionary.langHash[LW.gameBoard.model.translateToLanguage]
    console.log 'langs', lang1, lang2
    url = "http://api.wordreference.com/44241/json/"
    url += if lang1 == 'en' then lang1 + lang2 else lang1 + 'en'
    url += "/" + word + "?callback=?"

  handleTranslation: (data) ->
    console.log data
    if data.term0.PrincipalTranslations
      translations = data.term0.PrincipalTranslations
    else
      translations = data.term0.AdditionalTranslations

    term = translations[0].OriginalTerm.term
    termSense = translations[0].OriginalTerm.sense
    trans = translations[0].FirstTranslation.term
    termSense = translations[0].FirstTranslation.sense

    LW.gameBoard.$definitionBarText.html(
      term + ' (' + termSense + '): ' + 
      trans + ' (' + termSense + ')'
    )
