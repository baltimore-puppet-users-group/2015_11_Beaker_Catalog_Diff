require 'spec_helper_acceptance'

test_name 'Catalog Diff'

describe 'Catalog Diff Tool' do

  let(:manifest) {
    <<-EOS
      include 'diff_test'
    EOS
  }

  hosts.each do |host|
    context 'build present catalog' do
      it 'should work' do
        result = apply_manifest_on(
          host,
          manifest,
          :catch_failures => true
        )

        client_info = fact_on(host,'os')
        tmp_manifest = result.cmd.split(/\s+/).last
        output_catalog = %(#{fact_on(host,'fqdn')}-#{client_info['name']}-#{client_info['release']['full']}-present-catalog.json )

        manifestdir = host.puppet['manifestdir']
        on(host, %(mkdir -p #{manifestdir} && mv #{tmp_manifest} #{manifestdir}/site.pp))

        on(
          host,
          %(puppet master --compile #{fact_on(host,'fqdn')} > #{output_catalog})
        )
      end
    end
    context 'build future catalog' do
      it 'should work' do
        apply_manifest_on(
          host,
          manifest,
          :catch_failures => true,
          :future_parser => true
        )
      end
    end
  end
end
