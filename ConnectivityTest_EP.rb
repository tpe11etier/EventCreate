require 'savon'
require 'yaml'
require 'logger'

FILE = open('output.log', File::WRONLY | File::APPEND | File::CREAT)
LOGGER = Logger.new(FILE)
LOGGER.level = Logger::DEBUG

begin
  CONFIG = YAML.load_file("config.yml")
rescue Exception => e
  puts "No such file or directory - config.yml  Exiting."
  LOGGER.debug { "No such file or directory - config.yml  Exiting." }
  Process.exit
end

if CONFIG["companyName"] == "CHANGEME"
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
      #@client = Savon::Client.new("https://developer4.envoyww.com/WebService/EPAPI_1.0/wsdl.wsdl")
      @client = Savon::Client.new("https://profiles-api.vrli.com/WebService/EPAPI_1.0/wsdl.wsdl")
      @client.http.auth.ssl.verify_mode = :none
      @client.wsdl.soap_actions
      @header = { :AuthHeader => {
          :Domain => "EXCHANGE",
          :UserId => "EP_API_ADMIN",
          :UserPassword => "xxx",
          :OemId => "xxx",
          :OemPassword => "xxx"
        }
      }

      service = client.request :organization_query_root do
        soap.header = header
        soap.body = {}
      end
      @orgid = service.to_hash[:organization_query_root_response][:organization][:organization_id]
    rescue Savon::HTTP::Error => fault
      LOGGER.debug {"ERROR: An error has occurred: " + fault.to_s}
      abort("ERROR: An error has occurred: " + fault.to_s)
    rescue Savon::SOAP::Fault => fault
      result = fault.to_s
      if result.include?('Credential Check Failed')
        LOGGER.debug { "Credential Check Failed!"}
      else
        LOGGER.debug {"ERROR: An error has occurred: " + fault.to_s}
        abort("ERROR: An error has occurred: " + fault.to_s)
      end
    rescue => fault
      LOGGER.debug {"ERROR: An error has occurred: " + fault.to_s}
      abort("ERROR: An error has occurred: " + fault.to_s)
    end
  end
end



def create_event(svc)
  begin
    service = svc.client.request :event_create do
      soap.header = svc.header
      soap.body = {:Events => {:Event => {
          :EventTypeId => "khb33kkkk",
          :EventTeams => {:EventTeam => {:TeamId => "ky52bkkkk"}},
          :EventArgs => {:EMAIL_ADDR => {:Name => "EMAIL_ADDR", :Value => "support@varolii.com"},
                         :SUBJECT => {:Name => "SUBJECT", :Value => "#{CONFIG["companyName"]} - Testing Profiles API Connectivity."},
                         :BODY => {:Name => "BODY", :Value => "This is just a test."},
                         :THEME => {:Name => "PRE_THEME", :Value => "EXCHANGE:general;EXCHANGE:;VOICETALENT:DAVID;SON:M_ENG_4"},
                         :SENDER => {:Name => "SENDER", :Value => "Varolii"}
            }
          }
        }
      }
    end
    LOGGER.debug { service.to_xml }
    LOGGER.debug { "SUCCESS: Event sent successfully." }
    puts "SUCCESS: Event sent successfully."
  rescue Savon::SOAP::Fault => fault
    LOGGER.debug { fault.to_s }

  end
end


if __FILE__ == $0
  svc = Service.new
  create_event(svc)
  LOGGER.close
end



