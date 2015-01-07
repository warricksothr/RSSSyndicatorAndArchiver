require 'net/http'
require 'logger'

class HTTPCacher 
  #default to 1 hour caching
  def initialize(base_dir, timeout=3600)
    @base_dir = base_dir
    @timeout = timeout
    @logger = Logger.new(STDOUT)
  end

  def get(url, key)
    cached_path = "#{@base_dir}/#{key}.cache"
    data = nil
    # If the cache file exists and is within the timeout
    #@logger.debug "cache exists: #{File.exists?(cached_path)}"
    #@logger.debug "last update: #{Time.now - File.mtime(cached_path)}"
    if File.exists?(cached_path) and (Time.now - File.mtime(cached_path) < @timeout)
      @logger.debug "Getting file #{key} from cache"
      File.open(cached_path,'r') do |f|
        gz = Zlib::GzipReader.new(f)
        data = gz.read
        gz.close
      end
    else
      @logger.debug "Getting file #{key} from URL #{url}"
      resp = Net::HTTP.get_response(URI.parse(url))
      data = resp.body
      
      File.open(cached_path, 'w') do |f|
        gz = Zlib::GzipWriter.new(f)
        gz.write data
        gz.close
      end
    end
    data
  end
end
