require 'spec_helper_acceptance'

test_name 'Catalog Diff'

diff_versions = {
  '3.8.4' => 'stuff...',
  '4.2.3' => 'other stuff...'
}

describe 'Catalog Diff Tool' do
  hosts.each do |host|
    context 'build vX catalog' do
      # TODO: Add useful stuff here
    end
    context 'build vY catalog' do
      # TODO: Add useful stuff here
    end
  end
end
