require 'spec_helper_acceptance'

test_name 'Catalog Diff'

describe 'Catalog Diff Tool' do

  let(:manifest) {
    <<-EOS
      include 'diff_test'
    EOS
  }

  _catalog_dir = File.join(File.dirname(__FILE__),'../../catalogs')
  let(:catalog_dir){ _catalog_dir }

  let(:run_id){ Time.now.strftime("%F_%H_%M_%S") }

  unless File.directory?(_catalog_dir)
    FileUtils.mkdir_p(_catalog_dir)
  end

  def collect_catalog(host,parser_type,tmp_manifest)
    output_catalog = %(#{run_id}-#{fact_on(host,'fqdn')}-#{fact_on(host,'operatingsystem')}-#{fact_on(host,'release')}-#{parser_type}-catalog.json )

    manifestdir = host.puppet['manifestdir']
    on(host, %(mkdir -p #{manifestdir} && mv #{tmp_manifest} #{manifestdir}/site.pp))

    catalog = on(host,%(puppet master --logdest=syslog --compile --parser=#{parser_type} #{fact_on(host,'fqdn')})).stdout

    File.open(File.join(catalog_dir,output_catalog),'w') do |fh|
      fh.puts(catalog)
    end
  end

  hosts.each do |host|
    ['current','future'].each do |parser_type|
      context "#{parser_type} parser" do
        it 'should work' do
          tmp_manifest = apply_manifest_on(
            host,
            manifest,
            :catch_failures => true
          ).cmd.split(/\s+/).last

          collect_catalog(host,parser_type,tmp_manifest)
        end
      end
    end
  end
end
