require 'spec_helper'

vip_config_file_001 = '/etc/ucarp/vip-001.conf'
vip_config_file_002 = '/etc/ucarp/vip-002.conf'
vip_config_file_003 = '/etc/ucarp/vip-003.conf'

describe 'ucarp::vip', :type => :define do

  # A bit of a hack to get around the package provider default to that on OSX, where these tests are written.
  provider_class = Puppet::Type.type(:package).provider(:yum)
  before :each do
    Puppet::Type.type(:package).stubs(:defaultprovider).returns(provider_class)
  end

  let(:title) { 'test_vip' }
  let(:params) {
    {
    :ensure         => 'present',
    :cluster_nodes  =>  ['nginx-01.example.com', 'nginx-02.example.com'],
    :vip_ip_address => '192.168.1.1',
    :node_id        => '001',
    }
  }

  #let(:cluster_name) {} # default: $name
  #let(:node_id) {}  # default: 001
  #let(:host_ip_address) {} # default: ::ipaddress
  #let(:app_password) {} # generated if not supplied.
  #let(:master_host) {} # default: undef
  #let(:network_interface) {} # default: eth0

  let(:facts) { {
   :osfamily                  => 'RedHat',
   :operatingsystemrelease    => '7.2',
   :operatingsystemmajrelease => '7',
   :ipaddress                 => '192.168.10.20',
   :fqdn                      => 'nginx-01.example.com'
  } }

  it { is_expected.to compile }

  it { is_expected.to contain_class('ucarp') }

  it { is_expected.to contain_package('ucarp') }

  it { is_expected.to contain_file(vip_config_file_001).with({
      'ensure' => 'present',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0400',
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

    let(:params) {
      {
      :ensure            => 'present',
      :cluster_name      => 'my_cluster',
      :cluster_nodes     =>  ['nginx-01.example.com', 'nginx-02.example.com'],
      :node_id           => '003',
      :host_ip_address   => '192.168.100.100',
      :vip_ip_address    => '192.168.100.200',
      :app_password      => 'mypassword',
      :master_host       => 'nginx-02.example.com',
      :network_interface => 'eth1',
      }
    }

    it { is_expected.to contain_file(vip_config_file_003).with_content /^ID="003"$/ }
    it { is_expected.to contain_file(vip_config_file_003).with_content /^VIP_ADDRESS="192.168.100.200"$/ }
    it { is_expected.to contain_file(vip_config_file_003).with_content /^PASSWORD="mypassword"$/ }
    it { is_expected.to contain_file(vip_config_file_003).with_content /^BIND_INTERFACE="eth1"$/ }
    it { is_expected.to contain_file(vip_config_file_003).with_content /^SOURCE_ADDRESS="192.168.100.100"$/ }
    it { is_expected.to contain_file(vip_config_file_003).with_content /^OPTIONS="--shutdown --preempt --advskew=10"$/ }

  end

  context 'when ensure is absent' do
    let(:params) {
      {
      :ensure         => 'absent',
      :cluster_nodes  =>  ['nginx-01.example.com', 'nginx-02.example.com'],
      :vip_ip_address => '192.168.1.1',
      :node_id        => '001',
      }
    }
    it { is_expected.to contain_file(vip_config_file_001).with_ensure('absent') }
  end

  context 'when current node is not present in cluster_nodes' do
    let(:params) {
      {
      :ensure         => 'absent',
      :cluster_nodes  =>  ['nginx-01.example.com', 'nginx-02.example.com'],
      :vip_ip_address => '192.168.1.1',
      :node_id        => '001',
      }
    }
    let(:facts) { {
     :osfamily                  => 'RedHat',
     :operatingsystemrelease    => '7.2',
     :operatingsystemmajrelease => '7',
     :ipaddress                 => '192.168.10.20',
     :fqdn                      => 'nginx-03.example.com'
    } }
    it {is_expected.to raise_error(Puppet::Error, /Current node must be included within the nodelist.  Value must be FQDN./) }
  end

  context 'when node_id is invalid' do
    let(:params) {
      {
      :ensure         => 'present',
      :cluster_nodes  =>  ['nginx-01.example.com', 'nginx-02.example.com'],
      :vip_ip_address => '192.168.1.1',
      :node_id        => '1234',
      }
    }
    it {is_expected.to raise_error(Puppet::Error, /Invalid value for Node ID.  Must be a value from "000" to "255"/) }
  end

  context 'when cluster_nodes is empty' do
    let(:params) {
      {
      :ensure         => 'present',
      :cluster_nodes  =>  [],
      :vip_ip_address => '192.168.1.1',
      :node_id        => '001',
      }
    }
    it {is_expected.to raise_error(Puppet::Error, /Cluster Nodes is expected./) }
  end

  context 'when cluster_nodes is undefined' do
    let(:params) {
      {
      :ensure         => 'present',
      :cluster_nodes  =>  :undef,
      :vip_ip_address => '192.168.1.1',
      :node_id        => '001',
      }
    }
    it {is_expected.to raise_error(Puppet::Error, /Cluster Nodes is expected./) }
  end

  context 'when current node is not present in cluster_nodes' do
    let(:params) {
      {
      :ensure         => 'absent',
      :cluster_nodes  =>  ['nginx-01.example.com', 'nginx-02.example.com'],
      :vip_ip_address => '192.168.1.1',
      :node_id        => '001',
      }
    }
    let(:facts) { {
     :osfamily                  => 'RedHat',
     :operatingsystemrelease    => '7.2',
     :operatingsystemmajrelease => '7',
     :ipaddress                 => '192.168.10.20',
     :fqdn                      => 'nginx-03.example.com'
    } }
    it {is_expected.to raise_error(Puppet::Error, /Current node must be included within the nodelist.  Value must be FQDN./) }
  end

  context 'when vip_ip_address is invalid' do
    let(:params) {
      {
      :ensure          => 'present',
      :cluster_nodes  =>  ['nginx-01.example.com', 'nginx-02.example.com'],
      :vip_ip_address  => '192.168.300.300',
      :node_id         => '001',
      }
    }
    it {is_expected.to raise_error(Puppet::Error, /"192.168.300.300" is not a valid IP address/) }
  end

  context 'when host_ip_address is invalid' do
    let(:params) {
      {
      :ensure          => 'present',
      :cluster_nodes   =>  ['nginx-01.example.com', 'nginx-02.example.com'],
      :vip_ip_address  => '192.168.2.2',
      :host_ip_address => '192.168.500.500',
      :node_id         => '001',
      }
    }
    it {is_expected.to raise_error(Puppet::Error, /"192.168.500.500" is not a valid IP address/) }
  end


end

at_exit { RSpec::Puppet::Coverage.report! }
