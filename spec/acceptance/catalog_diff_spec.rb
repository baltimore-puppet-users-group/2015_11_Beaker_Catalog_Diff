require 'spec_helper_acceptance'

test_name 'Catalog Diff'

describe 'Catalog Diff Tool' do

  let(:manifest) {
    <<-EOS
      include 'diff_test'
    EOS
  }

  _catalog_dir = File.join(ENVIRONMENT_SPEC[:project_root],'catalogs')
  let(:catalog_dir){ _catalog_dir }

  let(:run_id){ Time.now.to_f.to_s }

  unless File.directory?(_catalog_dir)
    FileUtils.mkdir_p(_catalog_dir)
  end

  def collect_catalog(parser_type)
    client_info = fact_on(host,'os')
    tmp_manifest = result.cmd.split(/\s+/).last
    output_catalog = %(#{run_id}-#{fact_on(host,'fqdn')}-#{client_info['name']}-#{client_info['release']['full']}-#{catalog_type}-catalog.json )

    manifestdir = host.puppet['manifestdir']
    on(host, %(mkdir -p #{manifestdir} && mv #{tmp_manifest} #{manifestdir}/site.pp))

    catalog = on(host,%(puppet master --compile --parser=#{parser_type} #{fact_on(host,'fqdn')})).stdout

    File.open(File.join(catalog_dir,output_catalog),'w') do |fh|
      fh.puts(catalog)
    end
  end

  hosts.each do |host|
    ['current','future'].each do |parser_type|
      context "#{parser_type} parser" do
        it 'should work' do
          result = apply_manifest_on(
            host,
            manifest,
            :catch_failures => true
          )

          collect_catalog(parser_type)
        end
      end
    end
  end
end
