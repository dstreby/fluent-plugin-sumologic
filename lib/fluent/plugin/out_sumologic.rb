# encoding: UTF-8
require 'net/http'
require 'date'

class Fluent::SumologicOutput< Fluent::BufferedOutput
  Fluent::Plugin.register_output('sumologic', self)

  config_param :host, :string,  :default => 'localhost'
  config_param :port, :integer, :default => 9200
  config_param :path, :string,  :default => '/'
  config_param :format, :string, :default => 'json'

  def initialize
    super
  end

  def configure(conf)
    super
  end

  def start
    super
  end

  def format(tag, time, record)
    [tag, time, record].to_msgpack
  end

  def shutdown
    super
  end

  def write(chunk)
    messages = []
    
    case @format
      when 'json'
        chunk.msgpack_each do |tag, time, record|
          messages << record.to_json
        end
      when 'text'
        chunk.msgpack_each do |tag, time, record|
          messages << record['message']
        end
    end

    http = Net::HTTP.new(@host, @port.to_i)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.set_debug_output $stderr

    request = Net::HTTP::Post.new(@path)
    request.body = messages.join("\n")
    http.request(request)
  end
end
