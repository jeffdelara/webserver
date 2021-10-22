require 'socket'

SERVER_ROOT = "public"

def main
    server = TCPServer.new 5000 # Server bind to port 5000

    loop do
        Thread.start(server.accept) do |client|
            request = client.readpartial(2048)
            request = parse(request)

            # parse the request response
            if request.fetch(:path) == "/"
                # Homepage
                data = File.binread("#{SERVER_ROOT}/index.html")
                response = "HTTP/1.1 200\r\n" +
                    "Content-Length: #{data.size}\r\n" +
                    "\r\n" +
                    "#{data}\r\n"

                client.write(response)

            else 
                data = File.binread("public/#{request.fetch(:path)}")
                response = "HTTP/1.1 200\r\n" +
                    "Content-Length: #{data.size}\r\n" +
                    "\r\n" +
                    "#{data}\r\n"

                client.write(response)
            end

            # close the connection
            client.close
        end
    end
end

def parse(request)
    method, path, headers = request.lines[0].split
    {
        method: method, 
        path: path, 
        headers: parse_headers(request)
    }
end

def parse_headers(request)
    headers = {}
    
    def normalize(header)
        header.gsub(":", "").downcase.to_sym
    end

    request.lines[1..-1].each do |line| 
        return headers if line == "\r\n"

        header, value = line.split
        header = normalize(header)
        headers[header] = value
    end
end

main
