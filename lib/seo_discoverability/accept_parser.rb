module SeoDiscoverability
  class AcceptParser
    Representation = Data.define(:html_q, :markdown_q, :markdown_named)

    def self.parse(accept_header)
      new(accept_header).parse
    end

    def initialize(accept_header)
      @accept_header = accept_header.to_s.strip
    end

    def parse
      return Representation.new(html_q: 1.0, markdown_q: 1.0, markdown_named: false) if @accept_header.empty?

      html_q = 0.0
      markdown_q = 0.0
      markdown_named = false

      @accept_header.split(",").each do |part|
        type, *params = part.strip.split(";")
        type = type.to_s.downcase.strip
        q = 1.0
        params.each do |param|
          key, value = param.split("=", 2).map(&:strip)
          next unless key == "q"

          q = Float(value)
        rescue ArgumentError
          q = 0.0
        end

        case type
        when "text/html"
          html_q = [html_q, q].max
        when "text/markdown"
          markdown_q = [markdown_q, q].max
          markdown_named = true
        when "*/*"
          html_q = [html_q, q].max
          markdown_q = [markdown_q, q].max
        end
      end

      Representation.new(html_q:, markdown_q:, markdown_named:)
    end
  end
end
