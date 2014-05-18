require "ipscan/version"
require "ipscan/cli"
require 'parallel'
require 'net/ping'
require 'socket'
require 'ruby-progressbar'

module IPScan

  def self.arp(ip)
    data = {}
    arp_line = `arp #{ip}`.split("\n").last
    arp_hash = arp_line.split(" ")
    case RbConfig::CONFIG['host_os']
    when /linux/i
      data = {name: arp_hash[0],  mac: arp_hash[2]}
    when /bsd|osx|mach|darwin/i
      data = {name: arp_hash[0],  mac: arp_hash[3]}
    else
      raise "host_os=#{RbConfig::CONFIG['host_os']} are not supported"
    end

    if data[:name]== "?"
      data[:name] = "<unknown>"
    end

    if arp_line.index("no entry")
      data[:mac]  = "<no entry>     "
    end
    data
  end

  def self.get_range_addresses(network_addr, start_host, last_host)
    addrs = []
    start_host.upto(last_host) do |i|
      addrs << "#{network_addr}.#{i}"
    end
    addrs
  end

  def self.get_netbios_info(range)
    nbtinfo = {}
    body_started = false
    result = `nbtscan #{range}`
    result.each_line do |line|
      if line.index("-----------")
        body_started = true
        next
      end
      next unless body_started
      h            = line.split(" ")
      ip           = h[0]
      netbios_name = h[1]
      nbtinfo[ip] = {netbios_name: netbios_name}
    end
    nbtinfo
  end

  def self.scan(range)
    unless range.index("-")
      range = range + "-254"
    end
    scan_result  = range.scan(/(.*)-(.*)/)[0]
    network_addr = scan_result[0].split(".")[0..2].join(".")
    start_host   = scan_result[0].split(".")[3].to_i
    last_host    = scan_result[1].to_i
    host_total   = (start_host..last_host).size
    puts "check #{network_addr}.#{start_host} ~ #{network_addr}.#{last_host}"

    netbios_info = {}
    if `which nbtscan` != ""
      netbios_info = get_netbios_info(range)
    end

    addrs = get_range_addresses(network_addr, start_host, last_host)

    results = []
    progressbar = ProgressBar.create(:total => host_total)
    Parallel.each(addrs, in_threads: 100) do |addr|
      data = {:ip => addr}
      data.merge!(arp(addr))
      pinger = Net::Ping::External.new(addr)
      if pinger.ping?
        if netbios_info[addr]
          data[:netbios_name] = netbios_info[addr][:netbios_name]
        else
          data[:netbios_name] = "<unknown>"
        end
        results << data
      end
      progressbar.increment
    end

    puts "IP Address \tMac Address     \tName         \tNetBIOS Name"
    results.each do |res|
      puts "#{res[:ip]} \t#{res[:mac]} \t#{res[:name]} \t#{res[:netbios_name]}"
    end
  end
end
