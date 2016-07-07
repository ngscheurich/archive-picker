require "httparty"

class Dti
  include HTTParty
  attr_reader :options
  base_uri "theadvocate.com"

  def initialize(cms_id = 1)
    @options = { query: { start_id: cms_id, num_stories: 1 } }
  end

  def stories
    self.class.get("/api/stories/nitf", @options)
  end
end
