module Stories
  class Parsed
    attr_reader :cms_id,
                :url,
                :publish_date,
                :time_updated,
                :headline,
                :subheadline,
                :byline,
                :body,
                :infobox,
                :location,
                :keywords,
                :section,
                :photos

    def initialize(json)
      @story = json
      @cms_id = @story["cms_id"]
      @url = @story["url"]
      @publish_date = localized_publish_date
      @time_updated = nil
      @headline = @story["headline"]
      @subheadline = @story["subheadline"]
      @byline = @story["byline"]
      @body = @story["body"]
      @infobox = @story["infobox"]
      @location = @story["location"]
      @section = blox_section
      @photos = all_photos
    end

    private

    def localized_publish_date
    end

    def blox_section
      Stories::Map.section(
        @story["category"],
        @story["subcategory"]
      )
    end

    def all_photos
      photos = []
      @story["photos"].each { |p| photos << p } if @story["photos"]
      photos
    end
  end
end
