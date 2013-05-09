module DictsHelper
  require 'rest_client'

  def make_definition_request(word)
    url = "http://services.aonaware.com"
    url += "/DictService.asmx/Define"
    p 
    response = RestClient.get url, { content_type: :http, params: { word: word }}
    p 'RESPONSE'
    p response
    response
  end
end
