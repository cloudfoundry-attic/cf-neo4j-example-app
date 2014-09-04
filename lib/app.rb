require 'cf-app-utils'
require 'neography'
require 'sinatra'

class Neo4jExampleApp < Sinatra::Base
  BIND_INSTRUCTIONS = %{
  You must bind a Neo4j service instance to this application.

  You can run the following commands to create an instance and bind to it:

    $ cf create-service p-neo4j development neo4j-instance
    $ cf bind-service neo4j-example neo4j-instance
    $ cf push
  }

  NEO4J_CONNECTION_DETAILS = CF::App::Credentials.find_all_by_all_service_tags(['neo4j', 'pivotal']).first

  ::Neography.configure do |config|
    config.server         = NEO4J_CONNECTION_DETAILS['host']
    config.port           = NEO4J_CONNECTION_DETAILS['http_port']
    config.authentication = 'basic'
    config.username       = NEO4J_CONNECTION_DETAILS['username']
    config.password       = NEO4J_CONNECTION_DETAILS['password']
  end if NEO4J_CONNECTION_DETAILS

  NEO4J_CLIENT = Neography::Rest.new

  before do
    content_type :json
    halt(500, BIND_INSTRUCTIONS) unless NEO4J_CONNECTION_DETAILS
  end

  error do |exception|
    halt(500, exception.message)
  end

  post '/nodes' do
    attributes = JSON.parse(request.body.read)
    node = NEO4J_CLIENT.create_node(attributes)
    node_id = node['self'].split('/').last.to_i

    status 201
    { id: node_id }.to_json
  end

  get '/nodes/:id' do
    begin
      node = NEO4J_CLIENT.get_node(params[:id])
      { attributes: node['data'] }.to_json
    rescue Neography::NodeNotFoundException
      404
    end
  end
end
