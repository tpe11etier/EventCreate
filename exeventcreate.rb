require "net/http"
require "uri"

# Token used to terminate the file in the post body. Make sure it is not
# present in the file you're uploading.
BOUNDARY = "AaB03x"

uri = URI.parse("https://xpress-api.vrli.com/mb/bin/pwisapi.dll")
file = "ex.xml"

post_body = []
post_body << File.read(file)


http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Post.new(uri.request_uri)
request.body = post_body.join
#request["Content-Type"] = "multipart/form-data, boundary=#{BOUNDARY}"

http.request(request)