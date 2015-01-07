require 'logger'
require_relative 'content'

# Parser Configuration Object
class ParserConfiguration
  @@loaded_parsers = {}
  def get_loaded_parsers
    @@loaded_parsers
  end
end

class Parser
  attr_reader :config, :default_parser

  def initialize(default_parser = 'rss')
    @default_parser = default_parser
    @config = ParserConfiguration.new
    @logger = Logger.new(STDOUT)
  end

  def get_loaded_parsers
    @config.get_loaded_parsers
  end

  def parse(parser, data)
    parsing_handler = nil
    #@logger.debug "Trying to parse with \"#{parser}\" parser"
    if @config.get_loaded_parsers.include?(parser)
      parsing_handler = @config.method(get_loaded_parsers[parser])
    else
      @logger.debug "Parser \"#{parser}\" not loaded, trying with default parser: #{@default_parser}"
      parsing_handler = @config.method(get_loaded_parsers[@default_parser])
    end
    parsing_handler.call(data)
  end
end
