class GameController < ApplicationController
  def landing
    render :landing
  end

  def get_dict
    # TODO: change file format so preprocessing isn't necessary
    @dict = []
    if params[:lang] == 'english'
      file = "#{Rails.root}/app/assets/dictionaries/eng_2of12.txt"
    end

    if file
      File.foreach(file) do |line| 
        line = line.strip
        if line.length >= 3 && line.index(/[-']/) == nil
          @dict << line 
        end
      end
      @dict = " #{@dict.join(' ')} "
    else
      @dict = ""
    end

    render json: { text: @dict }
  end

  def redirect
    redirect_to "/game"
  end
end
