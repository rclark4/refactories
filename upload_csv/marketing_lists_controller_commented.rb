class MarketingListsController < ApplicationController
  layout "main"
  #the marketing lists pages uses the "main" layout...

  def index
    @marketing_list = MarketingList.new
    #makes the marketing list
    @campaign = Campaign.new
    #makes the campaign
  end

  def create
    file = params[:file][:upload]
    #defines that file is the object ':file' and can be uploaded.
    @marketing_list = MarketingList.new(params[:marketing_list])
    #the object (@market_list), when stated makes a new marketing list.

    if csv? && formatted_headers? && @marketing_list.save
        #if they ALL save
      create_directory
      #itll create a directory
      path = File.join(@directory, "#{@marketing_list.id}.csv")
      #once saved it'll go into the directory and inside the directory itll go to the correct marketing list id of the csv
      File.open(path, "w") { |f| f.write(file.read) }
      #once moved to correct place itll open up and you can read it.
      flash[:notice] = 'File uploaded successfully. Please allow 5 minutes for processing.'
      #notcie will come up saying what is in those quotes.
    else
      flash[:notice] = 'File not uploaded. Please check format.'
      #if none of that works itll show a notice saying these quotes
    end

    redirect_to marketing_lists_path
    #once it is saved/or not it shall redirect to the index of market lists
  end

  private

  def csv?
    params[:file][:upload].content_type == "text/csv"
    #defines what csv is and that it is a file and can be uploaded. the content type is text/csv.
  end

  def formatted_headers?
    file = params[:file][:upload]
    #formatted_headers are a ':file' and can be uploaded
    options = { :headers => true, :col_sep => ",", :quote_char => "\x00" }
    #not sure...makes it so that 'formatted_headers' are known as :headers. dont know the second part..third part may have somethin to do with what the formatted_headers can consist of character-wise?..
    csv = FasterCSV.read(file.path, options)
    #csv's can be read through the headers?...
    incoming_file = []
    #an incoming file is empty..(empty array)

    csv.headers.select { |header| incoming_file << header }
    #nested...a csv header is an incoming file?//

    incoming_file == formatted_headers
    #the incoming file is a formated_header
  end

  def create_directory
    sector_id = params[:client][:sector_id]
    #a sector_id has a :client and an id
    root = "#{RAILS_ROOT}/public/system/marketing_lists/"
    #the root path (where they come from)for sector_id is the quotes.
    directories = [root, root += "#{current_user.id}/", root += "#{sector_id}/"]
    #there are roots within the directories. there's the 'root' + the current user's id, and there's the 'root' + the sector_id...oh and also the normal 'root' itself

    directories.each do |directory|
      Dir.mkdir(directory) unless File.exists?(directory)
      #each directory makes a directory within the directory (in other words..makes a file within the larger folder)..if the file already exists then it will go into the correct directory.
    end

    @directory = directories.last
    #the object (@directory), when stated is referenced to the last directory.
  end

  def formatted_headers
      #defines all the different 'formatted_headers'
    ["first_name",
     "last_name",
     "email",
     "company",
     "title",
     "street",
     "street2",
     "city",
     "state",
     "zip_code",
     "phone",
     "phone2",
     "home_phone",
     "mobile_phone",
     "fax",
     "home_fax"]
  end
end
