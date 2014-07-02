require 'csv'

class CampaignResultsProcessor
  attr_accessor :activities, :links

  def initialize activities, links
    @activities = activities
    @links = links
  end

  def formatted?
    activities_csv? && links_csv? && formatted_headers?
  end

  def formatted_headers?
    activities_formatted_headers? && links_formatted_headers?
  end

  def activities_formatted_headers?
    headers(activities) == activities_formatted_headers
  end

  def links_formatted_headers?
    headers(links) == links_formatted_headers
  end

  def headers(file)
    options = { :headers => true, :col_sep => ",", :quote_char => "\x00" }
    FasterCSV.read(file.path, options).headers.compact
  end

  def activities_formatted_headers
    ["Email", "Date", "Activity", "Location", "\"Email Client\"", "URL", "Groups"]
  end

  def links_formatted_headers
    ["Title", "URL", "\"Unique Clicks\"", "\"Total Clicks\"", "\"Most Recent\"", "Location"]
  end
end

class CSVThing
  attr_reader :file

  def initialize file
    @file = file
  end

  def csv?
    file.content_type == "text/csv"
  end
end
