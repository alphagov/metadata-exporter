require 'webrick'
class MetadataServer
  def initialize(port, metadata)
    @server = WEBrick::HTTPServer.new(:Port => port.to_i)
    @metadata = metadata
    @server.mount_proc '/' do |req, res|
        res.body = @metadata
    end
  end

  def update_metadata

  end

  def start!
    Thread.new { @server.start }
  end

  def stop!
   @server.shutdown 
  end
end
