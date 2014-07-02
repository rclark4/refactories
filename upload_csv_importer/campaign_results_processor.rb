require 'csv'

class CampaignResultsProcessor
  attr_accessor :activities, :links

  def initialize activities, links
    @activities = activities
    @links = links
  end

  def activities_csv?
    activities.content_type == "text/csv"
  end

  def links_csv?
    links.content_type == "text/csv"
  end

  def formatted?
    activities_csv? && links_csv? && formatted_headers?
  end

  def formatted_headers?
    activities_formatted_headers? && links_formatted_headers?
  end

  def activities_formatted_headers?
    headers(self.activities) == activities_formatted_headers
  end

  def links_formatted_headers?
    headers(self.links) == links_formatted_headers
  end

  def headers(file)
    options = { :headers => true, :col_sep => ",", :quote_char => "\x00" }
    csv = FasterCSV.read(file.path, options)
    incoming_file = []

    csv.headers.compact.select { |header| incoming_file << header }
  end

  def activities_formatted_headers
    ["Email", "Date", "Activity", "Location", "\"Email Client\"", "URL", "Groups"]
  end

  def links_formatted_headers
    ["Title", "URL", "\"Unique Clicks\"", "\"Total Clicks\"", "\"Most Recent\"", "Location"]
  end
end
