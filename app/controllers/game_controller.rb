class GameController < ApplicationController
  def landing
  end

  def get_dict
    lang = params[:lang]
    if ['english', 'spanish', 'vietnamese'].include? lang
      file = "#{Rails.root}/lib/dictionaries/#{lang}.txt"
    else
      file = "#{Rails.root}/lib/dictionaries/english.txt"
    end
    @dict = File.open(file).read
    @alpha = Game.letter_freq_hash(lang)

    render json: { text: @dict, alpha: @alpha }
  end

  def redirect
    redirect_to "/game"
  end
end
