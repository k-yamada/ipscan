# -*- coding: utf-8 -*-
require 'ipscan'
require 'thor'

module IPScan
  class CLI < Thor
    desc "range [SCAN_RANGE]", "scan 192.168.1.0-254"
    def range(range)
      IPScan.scan(range)
    end
  end
end
