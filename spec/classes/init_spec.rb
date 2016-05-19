require 'spec_helper'
describe 'ucarp' do

  context 'with default values for all parameters' do
    it { should contain_class('ucarp') }
  end
end
