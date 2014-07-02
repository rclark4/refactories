require 'csv'

class CSVFormatWhitelist
  attr_reader :file

  def self.includes? file
    new(file).includes?
  end

  def initialize file
    @file = file
  end

  def includes?
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

# example of dynamic subclass

class ActivitiesWhitelist < CSVFormatWhitelist
  def acceptable_formats
    [["Email", "Date", "Activity", "Location", "\"Email Client\"", "URL", "Groups"]]
  end
end

class LinkWhitelist < CSVFormatWhitelist
  def acceptable_formats
    [["Title", "URL", "\"Unique Clicks\"", "\"Total Clicks\"", "\"Most Recent\"", "Location"]]
  end
end

# ActivitiesWhitelist.includes?(file) && LinkWhitelist.includes?(file2)


# example of dynamic runtime subclass generation

CSVFormatWhitelist.new.acceptable_formats.each do |klass, headers|
  Object.const_set(klass, Class.new).class_eval do
    superclass = CSVFormatWhitelist

    define_method "acceptable_formats" do
      [headers]
    end
  end
end

# implementation example

# ActivitiesWhitelist.includes? file
# => true || false
# LinkWhitelist.includes? file
# => true || false
# MarketingWhitelist.includes? file
# => true || false
