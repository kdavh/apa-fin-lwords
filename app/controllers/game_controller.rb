class GameController < ApplicationController
  def landing
    render :landing
  end

  def get_dict
    lang = params[:lang]
    file = ""

    case lang
    when 'english'
      file = "#{Rails.root}/lib/dictionaries/eng-dict.txt"
    when 'spanish'

    when 'vietnamese'

    end

    if file.length != 0
      @dict = File.open(file).read
      @alpha = Game.letter_freq_hash(lang)
    else
      @dict = ""
      @alpha = {}
    end

    render json: { text: @dict, alpha: @alpha }
  end

  def redirect
    redirect_to "/game"
  end
end
