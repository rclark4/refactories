require 'csv'

class CampaignResultsProcessor
  attr_accessor :activities, :links

  def initialize activities, links
    @activities = activities
    @links = links
  end

  def formatted?
    activities_csv? && links_csv? && activities_formatted_headers? && links_formatted_headers?
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

  def acceptable_format?
    options = { :headers => true, :col_sep => ",", :quote_char => "\x00" }
    headers = FasterCSV.read(file.path, options).headers.compact

    acceptable_formats.any? { |format| format == headers }
  end

  def acceptable_formats
    [
      ["Email", "Date", "Activity", "Location", "\"Email Client\"", "URL", "Groups"],
      ["Title", "URL", "\"Unique Clicks\"", "\"Total Clicks\"", "\"Most Recent\"", "Location"]
    ]
  end
end
