require 'savon'
require 'yaml'


CONFIG = YAML.load_file("config.yml")


Gyoku.convert_symbols_to :camelcase

class Service
  attr_reader :orgid
  attr_reader :client
  attr_reader :header

  def initialize
    #Dev URL
    @client = Savon::Client.new("https://developer4.envoyww.com/WebService/EPAPI_1.0/wsdl.wsdl")
    @client.wsdl.soap_actions
    @header = { :AuthHeader => {
        :Domain => "xxx",
        :UserId => "xxx",
        :UserPassword => "xxx",
        :OemId => "xxx",
        :OemPassword => "xxx"
      }
    }

    begin
      service = client.request :organization_query_root do
        soap.header = header
        soap.body = {}
      end
      @orgid = service.to_hash[:organization_query_root_response][:organization][:organization_id]
    rescue Savon::SOAP::Fault => fault
      fault.to_s
    end
  end
end


def query_members_by_org(svc)
  begin
    service = svc.client.request :member_query_by_organization_id do
      soap.header = svc.header
      soap.body = {:organization_ids => svc.orgid, :index => 1, :length => 100}
    end
  rescue Savon::SOAP::Fault => fault
    fault.to_s
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
  rescue Savon::SOAP::Fault => fault
    fault.to_s

  end
end


if __FILE__ == $0
  svc = Service.new
  create_event(svc)
end



