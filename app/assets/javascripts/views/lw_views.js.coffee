LW.Views.MenuBar = Backbone.View.extend
  initialize: (options) -> 
    that = this
    @$el = $('#menu-bar')
    @$openMenuButton = @$('#menu-button')
    @$menu = @$('#menu')
    @$body = $('body')
    @timerView = new LW.Views.Timer({$el: @$('#timer')})
    @scoreView = new LW.Views.Score
      model: new LW.Models.Score()
      $el: @$('#score-display')

    # events
    @$openMenuButton.on 'click.menu-open', (event) ->
      that.openMenu(event)

    @$('#new-game-button').on 'click', (event) =>
      LW.Store.gameBoard.model.resetMatch()
      @nextRoundActions()

    @$('#next-round-button').on 'click', (event) =>
      @nextRoundActions()

  nextRoundActions: ->
    LW.Store.gameBoard.endRoundReset()
    $(document).trigger 'clearTimer'
    LW.Store.gameBoard.play()

  openMenu: (event) ->
    that = this
    @$menu.css('visibility', 'visible')
    @$openMenuButton.off 'click.menu-open'
    @$body.on 'click.menu-close', (event) ->
      that.closeMenu(event)

    event.stopPropagation()

  closeMenu: (event) ->
    that = this
    @$menu.css('visibility', 'hidden')
    @$body.off 'click.menu-close'
    @$openMenuButton.on 'click.menu-open', (event) ->
      that.openMenu(event)

    event.stopPropagation()

LW.Views.GameBoard = Backbone.View.extend
  initialize: (options) ->
    @$el = $('#game-board')
    @$loadingGif = $('#loading-gif')

  play: ->
    @$loadingGif.css('visibility', 'visible')
    if !!@model.get('dict').get('text') == false
      @model.get('dict').fetch
        success: (model, response, options) =>
          @model.get('dict').makeAlphabet()
          @prepForPlay()
    else
      @prepForPlay()

  prepForPlay: ->
    @$loadingGif.css('visibility', 'hidden')
    @model.startRound()
    @populateBoard()

    @startListeningForLetterClicks()

  populateBoard: ->
    lettersBar = @$('#letters-bar')
    lettersBar.empty()
    _.each @model.get('currentLetters'), (ltr, i) =>
      lettersBar.append(
        "<div class='letter-square' data-pos='#{i}' data-ltr='#{ltr}'>" +
        ltr + '</div>'
      )

  startListeningForLetterClicks: ->
    $wordBar = @$('#guess-word-bar-text')
    $letterSquares = @$('.letter-square')

    $letterSquares.on 'click.game', (event) =>
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
        $wordBar.append(ltr)

    @$('#delete-key').on 'click.game', (event) =>
      if @model.get('formedWordArray').length 

        # off of model
        ltr = @model.get('formedWordArray').pop()
        removedLetterPos = @model.get('pickedLettersMask').indexOf( ltr )
        @model.get('pickedLettersMask')[removedLetterPos] = false

        # off of view
        $letterSquares
          .filter('[data-pos="' + removedLetterPos + '"]')
          .removeClass('picked')
        $wordBar.html( $wordBar.html().slice(0, -1) )

    @$('#enter-key').on 'click.game', (event) =>
      # onto model
      @model.set 'formedWordArray', []
      @model.makePickedLettersMask()

      # onto view
      word = $wordBar.html()
      $wordBar.html('')
      $letterSquares.removeClass('picked')

      if @model.get('dict').has( word ) && !_.contains( @model.get('foundWords'), word )
        # onto model
        @model.get('foundWords').push( word )

        # onto view
        @displayFound(word)
      else

    # keypress shortcuts
    $(document).on 'keydown.game', =>
      key = event.which

      switch key
        when 13
          @$('#enter-key').trigger 'click'
        when 8
          @$('#delete-key').trigger 'click'
          event.preventDefault()
        else
          if key >= 65 && key <= 90
            ltr = String.fromCharCode(key).toLowerCase()
            $letterSquares
              .filter($('[data-ltr="' + ltr + '"]:not(.picked)'))
              .first()
              .trigger('click')

  displayFound: (word) ->
    @$('#found-word-display')
      .html(word).show().fadeOut(3000)
    @$('#found-words').append("<span class='word'>" + word + "</span>")

  readyBoardForWord: ->
    @$('#guess-word-bar-text').html('')
    @model.readyForNewWord()

  endRoundReset: ->
    # reset model, and count up points
    @model.endRound()

    # reset view
    @$('#guess-word-bar-text').html('')
    @$('#show-definition-bar-text').html('')
    @$('#found-words').html('')

    $(document).off('.game')
    @model.endRound()

LW.Views.Timer = Backbone.View.extend
  initialize: (options) ->
    @$el = options.$el

  start: ->
    that = this
    secs = 121
    counter = setInterval( ->
      timer()
    , 1000)

    $(document).on 'clearTimer', =>
      clearInterval(counter)

    timer = ->
      secs = secs - 1
      currentMinutes = Math.floor(secs / 60);
      currentSeconds = secs % 60;
      if (currentSeconds <= 9) then currentSeconds = "0" + currentSeconds;
      that.$el.html(currentMinutes + ":" + currentSeconds)
      if secs <= 0
        clearInterval(counter)
        LW.Store.gameBoard.endRound()
        # trigger round finish event

LW.Views.Score = Backbone.View.extend
  initialize: (options) ->
    @$el = options.$el
    @render()

    @listenTo @model, 'change', @render

  render: ->
    @$el.html( @model.get('pts') )

