LWords::Application.routes.draw do
  root to: "game#redirect"
  get "game", to: "game#landing"
  get "game/dict/:lang", to: "game#get_dict"

  get "dicts/:lang/lookup/:word", to: "dicts#lookup"
end
