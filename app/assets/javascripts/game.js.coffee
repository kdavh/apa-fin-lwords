window.LW =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  Store: {}
  dictionary: {}

  boot: ->
    LW.menuBar = new LW.Views.MenuBar
      el: $('#menu-bar')
    LW.gameBoard = new LW.Views.GameBoard
      model: new LW.Models.Game
        match: new LW.Models.Match
    new LW.Routers.R()
    Backbone.history.start()
