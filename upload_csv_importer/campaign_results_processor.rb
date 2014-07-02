require 'csv'

class CSVThing
  attr_reader :file

  def self.formatted? file
    new(file).formatted?
  end

  def initialize file
    @file = file
  end

  def formatted?
    csv? && acceptable_format?
  end

  def csv?
    file.content_type == "text/csv"
  end

  def size
    csv.size
  end

  def stage path
    File.open(path, "w") { |f| f.write(file.read) }
  end

  private

  def csv
    options = { :headers => true, :col_sep => ",", :quote_char => "\x00" }
    FasterCSV.read(file.path, options)
  end

  def acceptable_format?
    acceptable_formats.any? { |format| format == csv.headers.compact }
  end

  def acceptable_formats
    [
      ["Email", "Date", "Activity", "Location", "\"Email Client\"", "URL", "Groups"],
      ["Title", "URL", "\"Unique Clicks\"", "\"Total Clicks\"", "\"Most Recent\"", "Location"],
      ["first_name", "last_name", "email", "company", "title", "street", "street2", "city", "state", "zip_code", "phone", "phone2", "home_phone", "mobile_phone", "fax", "home_fax"]
    ]
  end
end

# CSVThing.formatted?(file) && CSVThing.formatted?(file2)
