require "nokogiri"

module Stories
  class Nitf
    attr_reader :story
    attr_reader :xml

    def initialize(story)
      @story = story
      @xml = builder.to_xml
    end

    def builder
      Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.nitf do
          nitf_head(xml)
          nitf_body(xml)
        end
      end
    end

    def nitf_head(xml)
      xml.head do
        xml.docdata { nitf_identified_content(xml) }
        xml.send(:"doc-id", "id-string" => "dti-#{@story.cms_id}")
        xml.pubdata(type: "web", "position.section" => @story.section)
        if content?(@story.publish_date)
          xml.send(:"date.release", norm: @story.publish_date)
        end
      end
    end

    def nitf_identified_content(xml)
      xml.identified_content do
        nitf_asset_type(xml)
        nitf_location(xml)
        nitf_keywords(xml)
      end
    end

    def nitf_asset_type(xml)
      xml.classifier(type: "tncms:asset", value: "asset")
    end

    def nitf_location(xml)
    end

    def nitf_keywords(xml)
      if content?(@story.keywords)
        xml.key_list do
          @story.keywords.split(", ").each { |k| xml.keyword(key: k) }
        end
      end
    end

    def nitf_body(xml)
      xml.body do
        nitf_body_head(xml)
        nitf_body_content(xml)
      end
    end

    def nitf_body_head(xml)
      xml.send(:"body.head") do
        nitf_hedline(xml)
        nitf_byline(xml)
      end
    end

    def nitf_hedline(xml)
      if content?(@story.headline) || content?(@story.subheadline)
        xml.hedline do
          xml.hl1(@story.headline) if content?(@story.headline)
          if content?(@story.subheadline)
            xml.hl2(class: "subheadline") { xml.<< @story.subheadline }
          end
        end
      end
    end

    def nitf_byline(xml)
      if content?(@story.byline)
        byline = @story.byline
        byline.gsub!(%r{<p> *</p>}, "")
        byline.gsub!(/[\n&#010;]/, "")
        byline.gsub!(/<p> /, "<p>")
        byline.gsub!(%r{ </p>}, "</p>")
        xml.byline { xml.<< byline }
      end
    end

    def nitf_body_content(xml)
      xml.send(:"body.content") do
        nitf_related_links(xml)
        nitf_body_text(xml)
        nitf_infobox(xml)
        # nitf_photos(xml)
      end
    end

    def nitf_related_links(xml)
    end

    def nitf_body_text(xml)
      if content?(@story.body)
        xml.p do
          xml.cdata @story.body.gsub(%r{\/\/ <!\[CDATA.*\]\]>}, "")
        end
      end
    end

    def nitf_infobox(xml)
      if content?(@story.infobox)
        xml.block(xmlns: "http://www.w3.org/1999/xhtml", class: "breakout") do
          xml.classifier(type: "tncms:related-content-type", value: "infobox")
          @story.infobox
        end
      end
    end

    def nitf_photos(xml)
      @story.photos.each do |photo|
        xml.media(:"media-type" => "image") do
          xml.send(:"media-metadata", name: "id", value: photo.photo_id)
          xml.send(:"media-reference", source: photo.source)
          unless photo.caption.nil?
            xml.send(:"media-caption") do
              xml.<< "<p>#{photo.caption.gsub(/&#151;/, '&mdash;')}</p>"
            end
          end
        end
      end
    end

    def content?(str)
      true unless str.nil? || str == ""
    end
  end
end
