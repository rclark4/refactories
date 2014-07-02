class MarketingListsController < ApplicationController
  layout "main"

  def index
    @marketing_list = MarketingList.new
    @campaign = Campaign.new
  end

  def create
    file = params[:file][:upload]
    @marketing_list = MarketingList.new(params[:marketing_list])

    if csv? && formatted_headers? && @marketing_list.save
      create_directory
      path = File.join(@directory, "#{@marketing_list.id}.csv")
      File.open(path, "w") { |f| f.write(file.read) }
      flash[:notice] = 'File uploaded successfully. Please allow 5 minutes for processing.'
    else
      flash[:notice] = 'File not uploaded. Please check format.'
    end

    redirect_to marketing_lists_path
  end

  private

  def csv?
    params[:file][:upload].content_type == "text/csv"
  end

  def formatted_headers?
    file = params[:file][:upload]
    options = { :headers => true, :col_sep => ",", :quote_char => "\x00" }
    csv = FasterCSV.read(file.path, options)
    incoming_file = []

    csv.headers.select { |header| incoming_file << header }

    incoming_file == formatted_headers
  end

  def create_directory
    sector_id = params[:client][:sector_id]
    root = "#{RAILS_ROOT}/public/system/marketing_lists/"
    directories = [root, root += "#{current_user.id}/", root += "#{sector_id}/"]

    directories.each do |directory|
      Dir.mkdir(directory) unless File.exists?(directory)
    end

    @directory = directories.last
  end

  def formatted_headers
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
