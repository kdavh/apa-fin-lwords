LW.Views.MenuBar = Backbone.View.extend
  initialize: (options) -> 
    @$openMenuButton = @$('#menu-button')
    @$menu = @$('#menu')
    @$body = $('body')

    @timerView = new LW.Views.Timer({el: @$('#timer')})
    @scoreView = new LW.Views.Score
      model: new LW.Models.Score()
      el: @$('#score-display')

  events:
    'click.menu-open #menu-button'  : 'openMenu'
    'click #new-game-button'        : 'startMatch'
    'click #next-round-button'      : 'nextRound'

  openMenu: (event) ->
    @$menu.removeClass('hidden')
    @$body.on 'click.menu-close', (event) =>
      @closeMenu(event)

    event.stopPropagation()

  closeMenu: (event) ->
    @$menu.addClass('hidden')
    @$body.off 'click.menu-close'

    event.stopPropagation()

  startMatch: ->
    # logic
    LW.gameBoard.getDictionary()

    LW.gameBoard.cleanUpListeners()
    LW.gameBoard.model.saveAndDeleteOldMatch()
    LW.gameBoard.model.emptyForRound()
    LW.gameBoard.model.makeAndPrepNewMatch()

    #logic and ui
    @timerView.stop()
    @timerView.start()

    # ui
    LW.gameBoard.hideEndRoundDisplay()
    LW.gameBoard.emptyForRound()
    LW.gameBoard.populatePickLetters()
    LW.gameBoard.startListening()

LW.Views.GameBoard = Backbone.View.extend
  initialize: (options) ->
    @$el = $('#game-board')
    @initJquerySelectors()

    @matchInProgress = false
    # @currentLanguage = 'english'

  initJquerySelectors: ->
    @$loadingGif = @$('#loading-gif')
    @$endRoundDisplay = @$('#end-round-display')
    @$guessWordBarText = @$('#guess-word-bar-text')
    @$pickLettersBar = @$('#pick-letters-bar')
    @$foundWordsBarText = @$('#found-words-bar-text')
    @$deleteKey = @$('#delete-key')
    @$enterKey = @$('#enter-key')
    # @$letterSquares defined later


  startNewRound: ->
    # logic
    @model.emptyForRound()
    @model.prepNewRound()
    @cleanUpListeners()

    #logic and ui
    LW.menuBar.timerView.stop()
    LW.menuBar.timerView.start()

    #view
    @hideEndRoundDisplay()
    @emptyForRound()
    @populatePickLetters()
    @startListening()

  emptyForRound: ->
    @$('#pick-letters-bar').empty()
    @$guessWordBarText.empty()
    @$('#show-definition-bar-text').empty()
    @$foundWordsBarText.empty()

  # emptyPickLetters: ->


  getDictionary: ->
    @fetchNewDictionary() unless LW.dictionary[@model.currentLanguage]    

  fetchNewDictionary: ->
    @$loadingGif.show()
    LW.dictionary[@model.currentLanguage] = new LW.Models.Dictionary
      language: @model.currentLanguage

    LW.dictionary[@model.currentLanguage].fetch
      success: (model, response, options) =>
        @$loadingGif.hide()

  # prepForPlay: ->
  #   @model.startRound()
  #   @populateBoard()

  #   @startListeningForLetterClicks()

  populatePickLetters: ->
    lettersBar = @$('#pick-letters-bar')
    _.each @model.get('currentLetters'), (ltr, i) =>
      lettersBar.append(
        "<div class='letter-square' data-pos='#{i}' data-ltr='#{ltr}'>" +
        ltr + '</div>'
      )

  cleanUpListeners: ->
    @$('.letter-square').off 'click.game'
    @$deleteKey.off 'click.game'
    @$enterKey.off 'click.game'
    $(document).off 'keydown.game'

  startListening: ->
    @$letterSquares = @$('.letter-square')

    @addLetterSquaresClickListeners()
    @addDeleteClickListener()
    @addEnterClickListener()
    @addKeyboardListeners()
    @addNewRoundListeners()

  addLetterSquaresClickListeners: ->
    @$letterSquares.on 'click.game', (event) =>
      $target = $(event.currentTarget)
      pos = $target.attr('data-pos')
      ltr = $target.attr('data-ltr')

      # if letter hasn't been clicked, add it to view
      # and add to game model's records
      if @model.get('pickedLettersMask')[pos] == false

        # onto model
        @model.get('pickedLettersMask')[pos] = ltr
        @model.get('formedWordArray').push(ltr)

        # onto view
        $target.addClass('picked')
        @$guessWordBarText.append(ltr)

  addDeleteClickListener: ->
    @$deleteKey.on 'click.game', (event) =>
      if @model.get('formedWordArray').length 

        # off of model
        ltr = @model.get('formedWordArray').pop()
        removedLetterPos = @model.get('pickedLettersMask').indexOf( ltr )
        @model.get('pickedLettersMask')[removedLetterPos] = false

        # off of view
        @$letterSquares
          .filter('[data-pos="' + removedLetterPos + '"]')
          .removeClass('picked')
        @$guessWordBarText.html( @$guessWordBarText.html().slice(0, -1) )

  addEnterClickListener: ->
    @$enterKey.on 'click.game', (event) =>
      # onto logic
      @model.resetWordPick()
      # get word, and reset view
      word = @getAndResetWordPick()
      # on view
      @resetPickLettersBar()

      if @model.inDictionaryAndNotAlreadyChosen( word )
        # onto logic
        @model.addToFoundWords( word )
        # onto view
        @displayFound(word)

  addKeyboardListeners: ->
    $(document).on 'keydown.game', =>
      key = event.which

      switch key
        when 13
          @$enterKey.trigger 'click'
        when 8
          @$deleteKey.trigger 'click'
          event.preventDefault()
        else
          @pickLetterAndTriggerClick( key )

  addNewRoundListeners: ->
    @$endRoundDisplay.on 'click', =>
      @startNewRound()

  hideEndRoundDisplay: ->
    @$endRoundDisplay.fadeOut()

  pickLetterAndTriggerClick: (key) ->
    if key >= 65 && key <= 90
      ltr = String.fromCharCode(key).toLowerCase()
      @$letterSquares
        .filter($('[data-ltr="' + ltr + '"]:not(.picked)'))
        .first()
        .trigger('click')

  getAndResetWordPick: ->
    word = @$guessWordBarText.html()
    @$guessWordBarText.empty()
    word

  resetPickLettersBar: ->
    @$letterSquares.removeClass('picked')

  displayFound: (word) ->
    @$('#found-word-display')
      .html(word).show().fadeOut(3000)
    @$foundWordsBarText.append("<span class='word'>" + word + "</span>")

  endRound: ->
    points = @model.countPoints()
    @model.incrementPoints( points )
    @openEndRoundDisplay(points)

  openEndRoundDisplay: (points) ->
    bottomEdgePosition = @$('#guess-word-bar').outerHeight() +
                          @$pickLettersBar.outerHeight()
    @$endRoundDisplay
      .find('.end-round-score-display')
      .html('You scored ' + points + ' points!')
    @$endRoundDisplay
      .css('height', bottomEdgePosition)
      .fadeIn()

  # endRoundReset: ->
  #   # reset model, and count up points
  #   @model.endRound()

  #   # reset view
  #   @$guessWordBarText.html('')
  #   @$('#show-definition-bar-text').html('')
  #   @$foundWordsBarText.html('')

  #   $(document).off('.game')
  #   @model.endRound()

LW.Views.Timer = Backbone.View.extend
  start: ->
    @secs = 6
    @render()

    @timer = setInterval( =>
      @secs -= 1
      @render()
      @checkForTimeUp()
    , 1000)

  render: ->
    secsInMins = @toMins(@secs)
    @$el.html(secsInMins)

  toMins: (secs) ->
    currentMinutes = Math.floor(secs / 60);
    currentSeconds = secs % 60;
    if (currentSeconds <= 9) then currentSeconds = "0" + currentSeconds

    return currentMinutes + ":" + currentSeconds

  checkForTimeUp: ->
      if @secs <= 0
        clearInterval(@timer)
        LW.gameBoard.endRound()

  stop: ->
    clearInterval(@timer) if @timer

LW.Views.Score = Backbone.View.extend
  initialize: (options) ->
    @render()

    @listenTo @model, 'change', @render

  render: ->
    @$el.html( @model.get('pts') )

