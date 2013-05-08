console.log 'in game'
window.LW =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  Store: {}

  boot: ->
    LW.Store.menuBar = new LW.Views.MenuBar()
    LW.Store.gameBoard = new LW.Views.GameBoard
      model: new LW.Models.Game
    new LW.Routers.R()
    Backbone.history.start()
$ ->
  LW.boot()
