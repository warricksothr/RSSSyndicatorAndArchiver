class Content
  attr_reader :title, :description, :link, :guid, :pub_date
  
  def initialize(title, description, link, guid, pub_date)
    @title = title
    @description = description
    @link = link
    @guid = guid
    @pub_date = pub_date
  end
end
