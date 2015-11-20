require 'spec_helper_acceptance'

test_name 'Catalog Diff'

describe 'Catalog Diff Tool' do

  let(:manifest) {
    <<-EOS
      include 'diff_test'
    EOS
  }

  hosts.each do |host|
    context 'build 3.X catalog' do
      it 'should work' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end
    end
    context 'build 4.X catalog (future parser)' do
      it 'should work' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end
    end
  end
end
