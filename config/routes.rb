LWords::Application.routes.draw do
  get "game", to: "game#landing"
  get "game/dict/:lang", to: "game#get_dict"
end
