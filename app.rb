require 'sinatra'
require 'sinatra/reloader' if development?
require 'slim'
require 'resolv'

module Lookup
  def instance_name(target_hostname)
    resolver = Resolv::DNS.new nameserver: ['8.8.8.8', '8.8.4.4']
    resource = resolver.getresources(target_hostname, Resolv::DNS::Resource::IN::CNAME).first

    return 404 if resource.nil?

    content_type 'text/plain'
    resource.name.to_s.gsub(/\A([^\.]+)\..+\Z/, '\1').gsub(/\A([^-]+)-.+/, '\1')
  end
end

helpers Lookup

get '/' do
  slim :index
end

get '/api/my_domain/:name' do |name|
  name = "#{name}.my.salesforce.com" unless name.match %r{.my.salesforce.com\Z}
  instance_name name
end

get '/api/community/:name' do |name|
  name = "#{name}.force.com" unless name.match %r{.force.com\Z}
  instance_name name
end

get '/api/generic/:name' do |name|
  instance_name name
end
