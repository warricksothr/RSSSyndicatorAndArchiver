require 'set'

class Feed
  attr_reader :items, :title, :description, :link, :last_build_date, :pub_date, :ttl, :guids

  def initialize(title, description, link, last_build_date, pub_date, ttl, items = [])
    @title = title
    @description = description
    @link = link
    @last_build_date = last_build_date
    @pub_date = pub_date
    @ttl = ttl
    if items.size > 0
      @items = items
    else 
      @items = []
    end
    @guids = Set.new []
  end

  def add_items(new_items)
    unique_items = []
    new_items.each do |item|
      unless @guids.include?(item.guid)
        @guids << item.guid
        unique_items << item
      end
    end
	if unique_items.size > 0
		@items << unique_items
	end
    @items.compact!
  end

  def include?(guid)
    @guids.include? guid
  end
end
