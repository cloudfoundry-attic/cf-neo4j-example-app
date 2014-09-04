require 'json'
require 'socket'
require 'timeout'

require 'childprocess'
require 'faraday'
require 'neography'

describe 'Neo4j Example Application' do

  before do
    @process = ChildProcess.build('rackup')
    @process.environment['VCAP_SERVICES'] = vcap_services.to_json
    @process.environment['RACK_ENV'] = 'production'
    @process.start
    @process.io.inherit!

    Timeout.timeout(5) do
      begin
        socket = TCPSocket.new 'localhost', 9292
        socket.close
      rescue
        sleep 0.1
        retry
      end
    end
  end

  after do
    @process.stop
  end

  let(:neo) { Neography::Rest.new }

  let(:connection) do
    Faraday.new(url: 'http://localhost:9292') do |faraday|
      faraday.adapter Faraday.default_adapter
    end
  end

  context 'when there is no neo4j service bound' do
    let(:vcap_services) { {} }

    it 'returns an error instructing the user how to bind a service to the app' do
      response = connection.get('/nodes/123')
      expect(response.status).to eq(500)
      expect(response.body).to include('cf bind-service neo4j-example neo4j-instance')
    end
  end

  context 'when there is a neo4j service bound' do
    let(:vcap_services) do
      {
        'neo4j' => [
          {
            name: 'neo4j_service_one',
            label: 'p-neo4j',
            tags: ['neo4j', 'pivotal'],
            plan: 'default',
            credentials: {
                host: 'localhost',
                http_port: 7474,
                https_port: 7475,
                username: 'user',
                password: 'pass'
            }
          }
        ]
      }
    end

    describe 'a POST to /nodes' do
      it 'returns a 201 status code' do
        response = connection.post('/nodes', { 'a1' => 'v1' }.to_json, 'Content-Type' => 'application/json ')
        expect(response.status).to eq(201)
      end

      it 'returns the id of the new node' do
        response = connection.post('/nodes', { 'a1' => 'v1' }.to_json, 'Content-Type' => 'application/json ')
        expect(JSON.parse(response.body)['id']).to be_a(Fixnum)
      end
    end

    describe 'a GET from /nodes/ID' do
      context 'when node exists' do
        before do
          response = connection.post('/nodes', { 'a1' => 'v1' }.to_json, 'Content-Type' => 'application/json ')
          @node_id = JSON.parse(response.body)['id']
        end

        it 'returns a 200 status code' do
          response = connection.get("/nodes/#{@node_id}")
          expect(response.status).to eq(200)
        end

        it 'returns the correct node attributes in the response body' do
          response = connection.get("/nodes/#{@node_id}")
          expect(JSON.parse(response.body)['attributes']).to eq('a1' => 'v1')
        end
      end

      context 'when node does not exist' do
        it 'returns a 404 status code' do
          response = connection.get('/nodes/666666')
          expect(response.status).to eq(404)
        end
      end
    end
  end
end
