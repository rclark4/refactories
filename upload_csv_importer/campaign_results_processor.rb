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
end

# example of hardcoded subclass option

class CSVFormatWhitelist
  # ...

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

# example of dynamic runtime subclass generation option

class CSVFormatWhitelist
  # ...

  def acceptable_format?
    acceptable_formats.values.any? { |format| format == csv.headers.compact }
  end

  def acceptable_formats
    {
      "ActivitiesWhitelist" => ["Email", "Date", "Activity", "Location", "\"Email Client\"", "URL", "Groups"],
      "LinkWhitelist" => ["Title", "URL", "\"Unique Clicks\"", "\"Total Clicks\"", "\"Most Recent\"", "Location"],
      "MarketingWhitelist" => ["first_name", "last_name", "email", "company", "title", "street", "street2", "city", "state", "zip_code", "phone", "phone2", "home_phone", "mobile_phone", "fax", "home_fax"]
    }
  end
end

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
