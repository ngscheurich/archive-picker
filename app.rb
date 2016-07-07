require "sinatra"
require "json"
require_relative "lib/dti"
require_relative "lib/stories"

get "/" do
  if request["cms_id"]
    @cms_id = request["cms_id"]
    http_response = Dti.new(@cms_id).stories
    json = JSON.parse(http_response.body)["stories"].first
    @story = Stories::Parsed.new(json)
  end

  erb :index
end

get %r{archive-.*} do
  content_type "application/octet-stream"

  @cms_id = /archive-([^\.]*)/.match(request.path_info)[1]

  http_response = Dti.new(@cms_id).stories
  json = JSON.parse(http_response.body)["stories"].first
  parsed = Stories::Parsed.new(json)

  Stories::Nitf.new(parsed).xml
end
