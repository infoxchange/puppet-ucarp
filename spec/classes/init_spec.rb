require 'spec_helper'

describe "ucarp", :type => :class do

  provider_class = Puppet::Type.type(:package).provider(:yum)
  before :each do
    Puppet::Type.type(:package).stubs(:defaultprovider).returns(provider_class)
  end

  let(:title) { 'ucarp_init' }

  let(:facts) { {
   :osfamily                  => 'RedHat',
   :operatingsystemrelease    => '7.2',
   :operatingsystemmajrelease => '7',
   :ipaddress                 => '192.168.10.20',
   :fqdn                      => 'nginx-01.example.com'
  } }

  it { should contain_class('ucarp::params') }

  it { should contain_anchor('ucarp::start') }
  it { should create_class('ucarp::install') }
  it { should create_class('ucarp::config') }
  it { should create_class('ucarp::service') }
  it { should contain_anchor('ucarp::end') }

  # INSTALL
  it { is_expected.to contain_package('ucarp').with_ensure('latest') }

  # CONFIG
  it { is_expected.to contain_sysctl('net.ipv4.ip_nonlocal_bind').with_value('1') }

  # SERVICE
  it { is_expected.to contain_service('ucarp').with(
      'ensure'     => 'running',
      'enable'     => 'true',
      'hasstatus'  => 'true',
      'hasrestart' => 'true'
    )
  }

  context 'when a package should not be managed' do
    let(:params) {
      {
        :manage_package => 'false',
      }
    }

    it 'has no package resources with title => ucarp' do
       expect(catalogue.resources.select { |r| r.type == 'Package' && r[:title] == 'ucarp' }).to be_empty
    end
  end


  context 'when a specific package be managed' do
    let(:params) {
      {
        :manage_package => 'true',
        :package_ensure => '4.2.0',
        :package_name => 'ucarp-x',
      }
    }

    it { is_expected.to contain_package('ucarp-x').with_ensure('4.2.0') }
  end

end

