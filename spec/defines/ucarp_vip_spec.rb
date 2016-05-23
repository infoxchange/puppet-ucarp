require 'spec_helper'

vip_config_file_001 = '/etc/ucarp/vip-001.conf'
vip_config_file_002 = '/etc/ucarp/vip-002.conf'
vip_config_file_003 = '/etc/ucarp/vip-003.conf'

describe "ucarp::init" do
  let(:title) { 'ucarp_init' }

  it { should create_class('ucarp::install')}
  it { should create_class('ucarp::config')}
  it { should create_class('ucarp::service')}
end

describe 'ucarp::vip', :type => :define do

  let(:title) { 'test_vip' }
  let(:cluster_nodes ) { ['nginx-01.example.com','nginx-02.example.com'] }
  let(:vip_ip_address) { '192.168.1.1' }

  #let(:cluster_name) {} default: $name
  #let(:node_id) {}  default: 001
  #let(:host_ip_address) {} default: ::ipaddress
  #let(:app_password) {}
  #let(:master_host) {} default: undef
  #let(:network_interface) {} default: eth0

  let(:facts) { {
   :osfamily               => 'RedHat',
   :operatingsystemrelease => '7.2',
   :ipaddress              => '192.168.10.20',
   :fqdn                   => 'nginx-01.example.com'
  } }

  it { is_expected.to compile }

  it { is_expected.to contain_class('::ucarp') }

  it { is_expected.to contain_package('ucarp') }

  it { is_expected.to contain_file(vip_config_file_001).with({
      'ensure' => 'present',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0755',
    })
  }


  context 'when passing in minimum required parameters' do

    it { is_expected.to contain_file(vip_config_file_001).with_content /^ID="001"$/ }
    it { is_expected.to contain_file(vip_config_file_001).with_content /^VIP_ADDRESS="192.168.1.1"$/ }
    it { is_expected.to contain_file(vip_config_file_001).with_content /^BIND_INTERFACE="eth0"$/ }
    it { is_expected.to contain_file(vip_config_file_001).with_content /^SOURCE_ADDRESS="192.168.10.20"$/ }
    it { is_expected.to contain_file(vip_config_file_001).with_content /^OPTIONS="--shutdown --preempt --advskew=10"$/ }

  end

  context 'when passing in all parameters' do
    let(:cluster_name) { 'my_cluster' }
    let(:node_id) { '003' }
    let(:host_ip_address) { '192.168.100.100' }
    let(:vip_ip_address) { '192.168.100.200' }
    let(:app_password) {}
    let(:master_host) { 'nginx-02.example.com' }
    let(:network_interface) { 'eth1' }

    it { is_expected.to contain_file(vip_config_file_003).with_content /^ID="003"$/ }
    it { is_expected.to contain_file(vip_config_file_003).with_content /^VIP_ADDRESS="192.168.100.200"$/ }
    it { is_expected.to contain_file(vip_config_file_003).with_content /^BIND_INTERFACE="eth1"$/ }
    it { is_expected.to contain_file(vip_config_file_003).with_content /^SOURCE_ADDRESS="192.168.100.100"$/ }
    it { is_expected.to contain_file(vip_config_file_003).with_content /^OPTIONS="--shutdown --preempt --advskew=10"$/ }

  end

  context 'when cluster_nodes is empty' do
    let(:cluster_nodes ) { [] }
    it {is_expected.to raise_error(Puppet::Error, /cluster_nodes TBA/) }
  end

  context 'when host_ip_address is invalid' do
    let(:host_ip_address ) { '' }
    it {is_expected.to raise_error(Puppet::Error, /host_ip_address TBA/) }
  end

  context 'when vip_ip_address is invalid' do
    let(:vip_ip_address ) { '' }
    it {is_expected.to raise_error(Puppet::Error, /vip_ip_address TBA/) }
  end

  context 'when network_interface is missing' do
    let(:network_interface ) { '' }
    it {is_expected.to raise_error(Puppet::Error, /Network Interface is expected/) }
  end

  context 'when node_id is missing' do
    let(:node_id ) { '' }
    it {is_expected.to raise_error(Puppet::Error, /Node ID is expected/) }
  end

end

at_exit { RSpec::Puppet::Coverage.report! }


