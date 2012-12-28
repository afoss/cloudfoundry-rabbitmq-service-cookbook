require File.expand_path('../support/helpers', __FILE__)

require 'sqlite3'

describe 'cloudfoundry-rabbitmq-service::node' do
  include Helpers::CFServiceRabbitMQTest

  before do
    # Give the service some time to start up.
    sleep 10
  end

  it 'creates a instances dir' do
    directory('/var/vcap/services/rabbit/instances').must_exist.with(:owner, 'cloudfoundry')
  end

  it 'creates a database' do
    file('/var/vcap/services/rabbit/rabbit_node.db').must_exist.with(:owner, 'cloudfoundry')
  end

  it 'creates a valid config file' do
    file("/etc/cloudfoundry/rabbit_node.yml").must_exist.with(:owner, 'cloudfoundry')
    YAML.load_file('/etc/cloudfoundry/rabbit_node.yml')
  end

  it 'creates a config file with the expected content' do
    config = YAML.load_file('/etc/cloudfoundry/rabbit_node.yml')
    {
      "capacity" => 200,
      "plan" => "free",
      "local_db" => "sqlite3:/var/vcap/services/rabbit/rabbit_node.db",
      "mbus" => "nats://nats:nats@localhost:4222/",
      "index" => 0,
      "base_dir" => "/var/vcap/services/rabbit/instances",
      "rabbitmq_log_dir" => "/var/log/cloudfoundry/rabbit",
      "pid" => "/var/run/cloudfoundry/rabbit_node.pid",
      "node_id" => "rabbitmq_node_0",
      "max_clients" => 1000,
      "rabbitmq_server" => "/srv/rabbitmq/rabbitmq-2.4.1/sbin/rabbitmq-server",
      "rabbitmq_start_timeout" => 10,
      # "supported_versions" => ["2.2"],
      # "default_version" => "2.2",
      # "mongod_path" => {
      #   "2.2" => "/usr/bin/mongod"
      # },
      # "mongorestore_path" => {
      #   "2.2" => "/usr/bin/mongorestore"
      # },
      # "mongod_options" => {
      #   "2.2" => ""
      # },
      "port_range" => {
        "first" => 10001,
        "last" => 20000
      },
      "admin_port_range" => {
        "first" => 20001,
        "last" => 30000
      },
      "migration_nfs" => "/mnt/migration",
      "logging" => {
        "level" => "info",
        "file" => "/var/log/cloudfoundry/rabbit_node.log"
      }
    }.each do |k,v|
      config[k].must_equal v
    end
  end

  it 'has no provisioned services' do
    db = sqlite('/var/vcap/services/rabbit/rabbit_node.db')
    rows = db.execute("select * from vcap_services_rabbit_node_provisioned_services")
    rows.must_equal []
  end

protected
  def sqlite(path)
    @sqlite ||= SQLite3::Database.new(path)
  end
end