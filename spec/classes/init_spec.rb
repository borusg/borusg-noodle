require 'spec_helper'
describe 'noodle' do
  context 'with default values for all parameters' do
    it { should contain_class('noodle') }
  end
end
