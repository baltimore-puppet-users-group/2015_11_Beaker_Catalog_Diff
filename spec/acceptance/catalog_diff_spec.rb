require 'spec_helper_acceptance'

test_name 'Catalog Diff'

describe 'Catalog Diff Tool' do

  before(:all) do
    sleep(1)
    @run_id = Time.now.strftime("%F-%H-%M-%S")
  end

  let(:manifest) {
    <<-EOS
      include 'diff_test'
    EOS
  }

  _catalog_dir = File.join(File.dirname(__FILE__),'../../catalogs')
  let(:catalog_dir){ _catalog_dir }


  unless File.directory?(_catalog_dir)
    FileUtils.mkdir_p(_catalog_dir)
  end

  def collect_catalog(host,parser_type,tmp_manifest)
    # TODO:  Need to set up directory structure for preserving hostname
    #output_catalog = %(#{@run_id}-#{fact_on(host,'fqdn')}-#{fact_on(host,'operatingsystem')}-#{fact_on(host,'operatingsystemrelease')}-#{parser_type}-catalog.json)
    output_catalog = %(#{fact_on(host,'fqdn')}-#{parser_type}-#{@run_id}-catalog.json)

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

  context 'do catalog diff' do
    it 'should diff the catalogs' do
      diff_host = hosts.first
      Dir.glob(File.join(_catalog_dir,'*current-catalog.json')).each do |current_catalog|
        future_catalog = current_catalog.gsub('current','future')

        scp_to(diff_host, current_catalog, diff_host.puppet['yamldir'])
        scp_to(diff_host, future_catalog, diff_host.puppet['yamldir'])

        puts on(diff_host,%(puppet catalog diff #{diff_host.puppet['yamldir']}/#{current_catalog} #{diff_host.puppet['yamldir']}/#{future_catalog})).stdout
      end
    end
  end
end
