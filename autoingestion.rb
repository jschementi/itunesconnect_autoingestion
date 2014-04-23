require './util/http_verify_none.rb'
require 'net/https'
require 'uri'
require 'cgi'

def main
  autoingestor = Autoingestion.new
  yesterday = (Time.new - 24*60*60).strftime("%Y%m%d")

  config = if File.exists?("config.hash")
    eval(File.new("config.hash").read())
  else
    {}
  end
  autoingestor.username = config["username"] || begin
    print "iTunes Connect email address:             "
    gets.strip!
  end
  autoingestor.password = config["password"] || begin
    print "iTunes Connect password:                  "
    gets.strip!
  end
  autoingestor.vendor_number = config["vendor_number"] || begin
    print "Vendor number:                            "
    gets.strip!
  end
  autoingestor.type_of_report = config['type_of_report'] || begin
    print "Type of report:                [Sales]    "
    gets.strip!
  end || 'Sales'
  autoingestor.date_type = config['date_type'] || begin
    print "Date type:                     [Daily]    "
    a = gets.strip!
    puts a
    a
  end || 'Daily'
  autoingestor.report_type = config['report_type'] || begin
    print "Report type:                   [Summary]  "
    gets.strip!
  end || 'Summary'
  autoingestor.report_date = config['report_date'] || begin
    print "Report date:                   [#{yesterday}] "
    a = gets.strip!
    puts a
    a
  end || yesterday

  autoingestor.perform_request
end

class Autoingestion

  ITUNES_URL = "https://reportingitc.apple.com/autoingestion.tft"

  attr_accessor :username
  attr_accessor :password
  attr_accessor :vendor_number
  attr_accessor :type_of_report
  attr_accessor :date_type
  attr_accessor :report_type
  attr_accessor :report_date

  def create_post_body
    data  = "USERNAME="     + CGI.escape(@username.to_s)       + "&"
    data += "PASSWORD="     + CGI.escape(@password.to_s)       + "&"
    data += "VNDNUMBER="    + CGI.escape(@vendor_number.to_s)  + "&"
    data += "TYPEOFREPORT=" + CGI.escape(@type_of_report.to_s) + "&"
    data += "DATETYPE="     + CGI.escape(@date_type.to_s)      + "&"
    data += "REPORTTYPE="   + CGI.escape(@report_type.to_s)    + "&"
    data += "REPORTDATE="   + CGI.escape(@report_date.to_s)
  end

  def perform_request
    uri = URI.parse(ITUNES_URL)
    
    request = Net::HTTP.new(uri.host, uri.port)
    request.use_ssl = true
    
    body = create_post_body
    headers = {'Content-Type' => 'application/x-www-form-urlencoded'}
    response = request.post2(uri.path, body, headers)

    if response['filename'] != nil
      filename = response['filename']
      f = File.new(filename, "w")
      f.write(response.body)
      f.close
      puts "File Downloaded Successfully (#{filename})"

      system("cp #{filename} #{filename}.bak")
      system("gunzip #{filename}")
      system("mv #{filename}.bak #{filename}")
      
    elsif response['errormsg'] != nil
      puts response['errormsg']
    else
      puts "No recognized response, dumping headers.."
      response.each_header do | key, value |
        puts "#{key}: #{value}"
      end
    end
  end

end

if __FILE__ == $PROGRAM_NAME
  main
end
