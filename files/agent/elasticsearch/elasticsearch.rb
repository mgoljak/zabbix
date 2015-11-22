#!/usr/bin/env ruby
# 
# == Synopsis
#
# pargs: Get Elasticsearch status and performance
#
# == Usage
#  check_elasticsearch.rb [OPTIONS]
# Get ElasticSearch health status and performance.
#
# Mandatory arguments to long options are mandatory for short options too.
#    -h, --host <host>            Hostname of instance, default: localhost
#    -p, --port <port>            Port of the ES instance, default: 9200
#    -r, --prefix <prefix>        API prefix, default: ''
#
#    -f, --failure-domain <dom>   Coma-separated list of ES attributes that
#                                 make up cluster's failure domain. Same
#                                 list used for configuring shard allocator.
#    -m, --master-nodes <nodes>   Master-eligible nodes number threshold.
#                                 make up cluster's failure domain. Same
#                                 list used for configuring shard allocator.
#
#    -c --zabbix-config <file>    Absolute path to the configuration file
#                                 for zabbix-sender
#    -S --zabbix-server <server>  Hostname or IP address of Zabbix server
#    -P --zabbix-port <port>      Port number of server trapper running on the
#                                 server. Default is 10051
#    -Z --zabbix-hostname <host>  Specify host name in zabbix that data will
#                                 be reported to. Default: fqdn of machine
#    -I --source-address <ip>     Specify source IP address for contacting
#                                 Zabbix server
#
#        --help                   Show this message
#

require "getoptlong"
require "rdoc/usage"
require "net/http"
require "json"


class CheckElasticsearch

  def initialize(host, port, prefix, faildom, masternodes)
    @host        = host
    @port        = port
    @prefix      = prefix
    @faildom     = faildom
    @masternodes = masternodes

    @healthmap = { 'red' => 2, 'yellow' => 1, 'green' => 0 }

    # puts "Initialized with: #{@host} #{@port} #{@prefix} #{@faildom} #{@masternodes}"
  end

  # TODO: add exceptions
  def get_json(uri,post='')
    resp = Net::HTTP.get_response(URI.parse(uri))
    data = resp.body

    # convert the JSON to native Ruby hash
    result = JSON.parse(data)

    # if the hash has 'Error' as a key, we raise an error
    if result.has_key? 'Error'
       raise "web service error"
    end

    result
  end

  def version
    about = get_json("http://#{@host}:#{@port}/#{@prefix}")
    about['version']['number']
  end

  # ES cluster health color and general information
  def health
    health = get_json("http://#{@host}:#{@port}/#{@prefix}_cluster/health")
    @no_nodes               = health['number_of_nodes']
    @no_dnodes              = health['number_of_data_nodes']
    @no_shards_active       = health['active_shards']
    @no_shards_relocating   = health['relocating_shards']
    @no_shards_initialising = health['initializing_shards']
    @no_shards_unassigned   = health['unassigned_shards']
    @cluster_health_color   = health['status'].downcase
    @cluster_health_color
  end

  def clusterstate
    state = get_json("http://#{@host}:#{@port}/#{@prefix}_cluster/state")
    @no_indices = state['metadata']['indices'].length
    @no_indices_closed = 0 
    state['metadata']['indices'].each do |indice|
      @no_indices_closed += 1 if indice[1]['state'] == 'close'
    end
    state
  end

  # Request a bunch of useful numbers for perfstat (number of get, search, indexing...)
  def clusterstats
    stats = get_json("http://#{@host}:#{@port}/#{@prefix}_nodes/stats?all=true")
    stats['nodes'].each do |currentnode|
      @total_docs          = currentnode[1]['indices']['merges']['total_docs']
      @total_size_in_bytes = currentnode[1]['indices']['merges']['total_size_in_bytes']
    end
    stats
  end

  def debug
    puts "General health:              #{@healthmap[health]}"
    puts "Number of nodes:             #{@no_nodes}"
    puts "Number of data nodes:        #{@no_dnodes}"
    puts "Number of active shards:     #{@no_shards_active}"
    puts "Number of shards reloc:      #{@no_shards_relocating}"
    puts "Number of shards init:       #{@no_shards_initialising}"
    puts "Number of shards unassigned: #{@no_shards_unassigned}"

    clusterstate
    puts "Number of indices (open):    #{@no_indices}"
    puts "Number of indices (close):   #{@no_indices_closed}"

    clusterstats
    puts "Total number of documets:    #{@total_docs}"
    puts "Total size in bytes:         #{@total_size_in_bytes}"
  end

  def zabbix_readconfig(zabbixconfig='/etc/zabbix/zabbix_agentd.conf')
    file = File.new(zabbixconfig, 'r')
    zabbixserver=nil
    zabbixport='10051'
    zabbixhostname=nil
    while (line = file.gets)
      case line
      when /^Server=/
        zabbixserver=line.sub(/^Server=/,'')
      when /^Port=/
        zabbixport=line.sub(/^Port=/,'')
      when /^Hostname=/
        zabbixhostname=line.sub(/^Hostname=/,'')
      end
    end
    zabbixhostname ||= Socket.gethostbyname(Socket.gethostname).first
    { 'zabbixserver' => zabbixserver, 'zabbixport' => zabbixport, 'zabbixhostname' => zabbixhostname.chomp }
  end

  def zabbix(zabbixserver=nil, zabbixport=nil, zabbixhostname=nil, zabbixsource=nil, zabbixconfig='/etc/zabbix/zabbix_agentd.conf', zabbixtmpfile='/var/tmp/zabbixSenderElasticsearch')
    settings = zabbix_readconfig(zabbixconfig)
    zabbixserver   ||= settings['zabbixserver']
    zabbixport     ||= settings['zabbixport']
    zabbixhostname ||= settings['zabbixhostname']
    file = File.new(zabbixtmpfile, 'w')
    file.truncate(0)
    file.write("#{zabbixhostname} elasticsearch.health            #{@healthmap[health]}\n")
    file.write("#{zabbixhostname} elasticsearch.no_nodes          #{@no_nodes}\n")
    file.write("#{zabbixhostname} elasticsearch.no_nodes_data     #{@no_dnodes}\n")
    file.write("#{zabbixhostname} elasticsearch.no_shards_active  #{@no_shards_active}\n")
    file.write("#{zabbixhostname} elasticsearch.no_shards_reloc   #{@no_shards_relocating}\n")
    file.write("#{zabbixhostname} elasticsearch.no_shards_init    #{@no_shards_initialising}\n")
    file.write("#{zabbixhostname} elasticsearch.no_shards_unass   #{@no_shards_unassigned}\n")

    clusterstate
    file.write("#{zabbixhostname} elasticsearch.no_indices_open   #{@no_indices}\n")
    file.write("#{zabbixhostname} elasticsearch.no_indices_closed #{@no_indices_closed}\n")

    clusterstats
    file.write("#{zabbixhostname} elasticsearch.no_docs_total     #{@total_docs}\n")
    file.write("#{zabbixhostname} elasticsearch.no_docs_diff      #{@total_size_in_bytes}\n")

    file.close

    system("/usr/bin/zabbix_sender -c #{zabbixconfig} -i #{zabbixtmpfile}")

    puts @healthmap[health]
  end

end
 
# main
if __FILE__==$0
  begin
    opts=GetoptLong.new(
      ["--help",            "-h", GetoptLong::NO_ARGUMENT],
      ["--host",            "-H", GetoptLong::REQUIRED_ARGUMENT],
      ["--port",            "-p", GetoptLong::REQUIRED_ARGUMENT],
      ["--prefix",          "-r", GetoptLong::REQUIRED_ARGUMENT],
      ["--failure-domain",  "-f", GetoptLong::REQUIRED_ARGUMENT],
      ["--master-nodes",    "-m", GetoptLong::REQUIRED_ARGUMENT],
      ["--zabbix-config",   "-c", GetoptLong::REQUIRED_ARGUMENT],
      ["--zabbix-server",   "-S", GetoptLong::REQUIRED_ARGUMENT],
      ["--zabbix-port",     "-P", GetoptLong::REQUIRED_ARGUMENT],
      ["--zabbix-hostname", "-z", GetoptLong::REQUIRED_ARGUMENT],
      ["--source-address",  "-I", GetoptLong::REQUIRED_ARGUMENT],
      ["--zabbix",  GetoptLong::NO_ARGUMENT]
    )

    # failsafe values
    host='localhost'
    port='9200'
    prefix=''
    faildom=[]
    masternodes=1
    zabbix=false
    zabbixserver=nil
    zabbixport=nil
    zabbixhostname=nil
    zabbixsource=nil
    zabbixconfig='/etc/zabbix/zabbix_agentd.conf'
    zabbixtmpfile='/var/tmp/zabbixSenderElasticsearch'

    # values set by options
    opts.each { |option, value|
      case option
      when "--help"
        RDoc::usage("Usage")
      when "--host"
        host = value
      when "--port"
        port = value
      when "--prefix"
        prefix = value
        # if not prefix.endswith('/'): prefix += '/
      when "--failure-domain"
        faildom = value
      when "--master-nodes"
        masternodes = value
      when "--zabbix-config"
        zabbixconfig = value
      when "--zabbix-server"
        zabbixserver = value
      when "--zabbix-port"
        zabbixport = value
      when "--zabbix-hostname"
        zabbixhostname = value
      when "--source-address"
        zabbixsource = value
      when "--zabbix"
        zabbix = true
      end
    }

    # do run
    es_check = CheckElasticsearch.new(host,port,prefix,faildom,masternodes)
    if zabbix
      es_check.zabbix(zabbixserver,zabbixport,zabbixhostname,zabbixsource,zabbixconfig,zabbixtmpfile)
    else
      es_check.debug
    end
  rescue Interrupt => e
    nil
  end
end
# EOF
