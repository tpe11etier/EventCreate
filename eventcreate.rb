require 'savon'
require 'yaml'
require 'logger'

LOGGER = Logger.new('output.log', 'w')
LOGGER.level = Logger::DEBUG

begin
  CONFIG = YAML.load_file("config.yml")
rescue Exception => e
  puts "No such file or directory - config.yml  Exiting."
  LOGGER.debug { "No such file or directory - config.yml  Exiting." }
  Process.exit
end

if CONFIG["companyName"] == "COMPANYNAME"
  puts "=" * 100
  puts "Please edit the config.yml file and change COMPANYNAME to your company name."
  puts "=" * 100
  Process.exit
end



Gyoku.convert_symbols_to :camelcase

class Service
  attr_reader :orgid
  attr_reader :client
  attr_reader :header

  def initialize
    begin
      @client = Savon::Client.new("https://developer4.envoyww.com/WebService/EPAPI_1.0/wsdl.wsdl")
      @client.http.auth.ssl.verify_mode = :none
      @client.wsdl.soap_actions
      @header = { :AuthHeader => {
          :Domain => "x",
          :UserId => "x",
          :UserPassword => "x",
          :OemId => "x",
          :OemPassword => "x"
        }
      }
    rescue Savon::HTTP::Error => fault
      LOGGER.debug { fault }
    rescue Savon::SOAP::Fault => fault
      LOGGER.debug { fault }
    end

    begin
      service = client.request :organization_query_root do
        soap.header = header
        soap.body = {}
      end
      @orgid = service.to_hash[:organization_query_root_response][:organization][:organization_id]
    rescue Savon::SOAP::Fault => fault
      result = fault.to_s
      puts result
      if result.include?('Credential Check Failed')
        LOGGER.debug { "Credential Check Failed!"}
      else
        LOGGER.debug { fault }
        fault.to_s
      end
    end
  end
end



def create_event(svc)
  begin
    service = svc.client.request :event_create do
      soap.header = svc.header
      soap.body = {:Events => {:Event => {
          :EventTypeId => 2634,
          :EventTeams => {:EventTeam => {:TeamId => "ks3d5kkkb"}},
          :EventArgs => {:EMAIL_ADDR => {:Name => "EMAIL_ADDR", :Value => "tony.pelletier@varolii.com"},
                         :SUBJECT => {:Name => "SUBJECT", :Value => "This is a Test Event from #{CONFIG["companyName"]}"},
                         :BODY => {:Name => "BODY", :Value => "This is a Test Event from #{CONFIG["companyName"]}"}
            }
          }
        }
      }
    end
    LOGGER.debug { service.to_xml }
  rescue Savon::SOAP::Fault => fault
    fault.to_s

  end
end


if __FILE__ == $0
  svc = Service.new
  create_event(svc)
  LOGGER.close
end



