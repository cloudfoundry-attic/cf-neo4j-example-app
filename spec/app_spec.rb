# rubocop:disable LineLength
ENV['VCAP_SERVICES'] = '{"neo4j":[{"label":"neo4j","tags":["neo4j","pivotal"],"credentials":{"host":"10.244.3.42","http_port":59306,"https_port":57620,"username":"5dd81d24","password":"92cd2f0"}}]}'
# rubocop:enable LineLength

require 'app'

describe Neo4jExampleApp do
  it 'should configure Neography according to the neo4j credentials in VCAP_SERVICES' do
    neo_config = ::Neography.configuration

    expect(neo_config.server).to eq('10.244.3.42')
    expect(neo_config.port).to eq(59_306)
    expect(neo_config.authentication).to eq('basic')
    expect(neo_config.username).to eq('5dd81d24')
    expect(neo_config.password).to eq('92cd2f0')
  end
end
