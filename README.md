# IPScan

Scans your local area network to determine the identity of all machines on the LAN.

## Installation

### Mac OS X

    $ gem install ipscan

### Linux (Ubuntu)

    $ sudo apt-get install nbtscan
    $ gem install ipscan

## Usage

    $ ipscan range 192.168.1.0-254
    check 192.168.1.0 ~ 192.168.1.254
    Progress: |==========================================================================================================================================|
    IP Address 	Mac Address     	Name         	NetBIOS Name
    192.168.1.1 	xx:xx:xx:xx:xx:xx	abc.me  	ABC
    192.168.1.190 	<no entry>      	xxxxxx  	<unknown>
    192.168.1.232	xx:xx:xx:xx:xx:xx	xxxxxx  	XXXXX

## Contributing

1. Fork it ( http://github.com/<my-github-username>/ipscan/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
