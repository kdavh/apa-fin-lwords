class DictsController < ApplicationController
  include DictsHelper

  respond_to :json

  def lookup
    # lang = params[:lang]
    # word = params[:word]

    # if lang == 'spanish'

    # elsif lang == 'vietnamese'

    # else
    #   response = make_definition_request( word )
    #   render json: response
    # end
  end
end
