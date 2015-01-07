require 'yaml/store'
require_relative 'feed'
require_relative 'content'
require 'logger'

class Archive
  attr_reader :dir

  def initialize(archive_dir)
    @dir = archive_dir


    # init logger
    @logger = Logger.new(STDOUT)
  end

  # Archive a feed to the archiveDirectory
  def archive_site(feed, feed_name)
    File.open("#{@dir}/#{feed_name}.store", 'w') do |f|
      gz = Zlib::GzipWriter.new(f)
      gz.write YAML.dump(feed)
      gz.close
    end
  end

  def load_site(feed_name)
    content = nil
    begin
      File.open("#{@dir}/#{feed_name}.store") do |f|
        gz = Zlib::GzipReader.new(f)
        content = YAML.load gz.read
        gz.close
      end
    rescue Exception => e
      @logger.error "Failed to deserialize #{feed_name}. Error: #{e}"
    end
    content
  end
end
