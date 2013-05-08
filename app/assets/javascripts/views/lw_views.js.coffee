LW.Views.MenuBar = Backbone.View.extend
  initialize: (options) -> 
    that = this
    @$el = $('#menu-bar')
    @$openMenuButton = @$('#menu-button')
    @$menu = @$('#menu')
    @$body = $('body')
    @timerView = new LW.Views.Timer({$el: @$('#timer')})

    # events
    @$openMenuButton.on 'click.menu-open', (event) ->
      that.openMenu(event)

    @$('#new-game-button').on 'click', (event) ->
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
          @prepPlay()
    else
      @prepPlay()

  prepPlay: ->
    @$loadingGif.css('visibility', 'hidden')
    @model.startRound()
    @populate()

    @startListeningForLetterClicks()

  populate: ->
    lettersBar = @$('#letters-bar')
    lettersBar.empty()
    _.each @model.get('currentLetters'), (ltr, i) =>
      lettersBar.append(
        "<div class='letter-square' data-pos='#{i}' data-ltr='#{ltr}'>" +
        ltr + '</div>'
      )

  startListeningForLetterClicks: ->
    $wordBar = @$('#guess-word-bar')
    $letterSquares = @$('.letter-square')

    $letterSquares.on 'click', (event) =>
      $target = $(event.currentTarget)
      pos = $target.attr('data-pos')

      # if letter hasn't been clicked, add it to view
      # and add to game model's records
      if @model.get('pickedLettersMask')[pos] == false

        # onto model
        @model.get('pickedLettersMask')[pos] = $target.attr('data-ltr')
        @model.get('formedWordArray').push($target.html())

        # onto view
        $target.addClass('picked')
        $wordBar.append($target.html())


    @$('#delete-key').on 'click', (event) =>
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


    @$('#enter-key').on 'click', (event) =>
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

    $(document).on 'keyup', =>
      console.log 'type'

  displayFound: (word) ->
    @$('#found-word-display')
      .html(word).show().fadeOut(3000)
    @$('#found-words').append("<div class='word'>" + word + "</div>")

  readyBoardForWord: ->
    @$('#guess-word-bar').html('')
    @model.readyForNewWord()

LW.Views.Timer = Backbone.View.extend
  initialize: (options) ->
    @$el = options.$el

  start: ->
    that = this
    secs = 120
    counter = setInterval( ->
      timer()
    , 1000)

    timer = ->
      secs = secs - 1
      currentMinutes = Math.floor(secs / 60);
      currentSeconds = secs % 60;
      if (currentSeconds <= 9) then currentSeconds = "0" + currentSeconds;
      that.$el.html(currentMinutes + ":" + currentSeconds)
      if secs <= 0
        clearInterval(counter)
        # trigger round finish event
