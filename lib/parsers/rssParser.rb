module RSSParser
  def rss_parser_parse(rss)
    title = rss.title
    description = rss.description
    link = rss.link
    if defined? rss.guid.content
      guid = rss.guid.content
    else
      guid = link
    end
    pub_date = rss.pubDate
    
    Content.new(title,description,link,guid,pub_date)
  end
end

class ParserConfiguration
  include RSSParser
  #insert itself into the list of parsers
  @@loaded_parsers['rss'] = :rss_parser_parse
end
