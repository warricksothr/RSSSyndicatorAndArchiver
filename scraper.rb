require 'rss'
require 'yaml'
require 'logger'

# Load local classes
require_relative 'lib/archive'
require_relative 'lib/httpCacher'
require_relative 'lib/parser'

# init logger
logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

# Read in yaml config
cfg = YAML.load_file('config.yml')
logger.debug "Read config file: #{cfg.inspect}"

# configure archive class
archiver = Archive.new(cfg['archiveDir'])
logger.debug("Created archive pointed at: #{archiver.dir}")

# configure parsers
logger.debug "Scanning #{cfg['parserPluginDir']} for parsing plugins"
Dir.glob("#{cfg['parserPluginDir']}/*.rb").each{|f| require f; logger.debug "Loading Parser: #{f}"}
parser = Parser.new()
logger.debug("Loaded parsers: #{parser.get_loaded_parsers.inspect}")
  
# load all the sites to parse
sites = Dir["#{cfg['siteConfigDir']}/*.yml"]
logger.debug "Found site configs: #{sites.inspect}"

sites.each do |site|
  logger.debug "Processing site: #{site}"
  site_cfg = YAML.load_file(site)
  logger.debug "Config for site: #{site_cfg.inspect}"
  unless site_cfg['active']
    logger.debug "Site: #{site} is currently disabled. Skipping Processing"
    next
  end
  # Grab feed
  rss_content = ""
  http_cacher = HTTPCacher.new(cfg['cacheDir'])
  rss_content = http_cacher.get(site_cfg['src'], site_cfg['archive'])
  # Parse the feed, dumping its contents to rss
  rss = RSS::Parser.parse(rss_content, false)
  channel = rss.channel
  #logger.debug "Got RSS: #{rss.inspect}"
  #logger.debug "Detected Channel: #{channel.inspect}"

  # Attempt to load an archive for the site if one already exists
  site_feed = archiver.load_site(site_cfg['archive'])
  if site_feed == nil
    # New Feed
    logger.debug 'detected new feed'
    site_feed = Feed.new(
      channel.title,
      channel.description,
      channel.link,
      channel.lastBuildDate,
      channel.pubDate,
      channel.ttl)
    #logger.debug "Created: #{site_feed.inspect}"
  else 
    # Existing Feed
    logger.debug 'detected existing feed'
    #logger.debug "Loaded: #{site_feed.inspect}"
  end

  # Consume the feed items
  items = []
  #logger.debug "Channel Items: #{channel.items.inspect}"
  channel.items.each do |item|
    parsed_item = parser.parse(site_cfg['parserClass'], item)
    #logger.debug "Parsed \"#{parsed_item.inspect}\" from \"#{item}\""
    items << parsed_item
  end

  #logger.debug "Parsed Items: #{items.inspect}"
  site_feed.add_items items
  #logger.debug "Updated Site Feed: #{site_feed.inspect}"

  # Save archive
  archiver.archive_site site_feed, site_cfg['archive']
  logger.debug "Saved site to archive"
end
