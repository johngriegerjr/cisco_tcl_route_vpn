# Author:     John Grieger
# Version:    1.0
# Date:       20161001
# File:       ChangeProxyACL.tcl
# Copyright:  Copyright (c) 2016 John Grieger

# Check if ipaddress.txt file exists
set checkfile [ file isfile ipaddress.txt]

# If ipaddress.txt does not exist, create it
if {$checkfile == "0"} {
	set filename "ipaddress.txt"
	# open filename for writing
	set fileId [open $filename "w"]
	# close filename after writing
	close $fileId
	puts "No file was found. One was created"
}

# Find current next hop for 10.160.0.0/19 
set ipall [ios_config {do sh ip route bgp | incl 10.160.0.0/19}]
set ipaddress [lindex $ipall 4] 
set nexthop [lindex [split $ipaddress ,] 0] 

# Read ipaddress.txt and set contents as variable $file_data
set fp [open "ipaddress.txt" r]
set file_data [read $fp]
close $fp

# Check if the current next hop is the same as the last time this
# script ran. If the next hop matches the old next hop, exit the 
# program so you aren't over writing the same ACL over and over
if {$file_data == $nexthop} {
	puts "No action needed. Routing for current next hop is correct."
	break
}

if {$file_data == ""} {
	set filename "ipaddress.txt"
	# open filename for writing
	set fileId [open $filename "w"]
	# Write current nexthop ip address to file
	puts -nonewline $fileId $nexthop
	# close filename after writing
	close $fileId
	puts "File was empty. It has been update with next hop"
}

set fp [open "ipaddress.txt" r]
set file_data [read $fp]
close $fp

set dst1 172.18.16.253
set dst2 172.18.16.254

if {$nexthop == $dst1} {
	ios_config "conf t" "ip access-list extended SPRINT-CDMA-2-ACL" "no permit ip any 10.160.0.0 0.0.31.255" "ip access-list extended SPRINT-CDMA-1-ACL" "20 permit ip any 10.160.0.0 0.0.31.255"
	puts "Proxy ACL has been modified to send traffic to .253"
} elseif {$nexthop == $dst2} {
	ios_config "conf t" "ip access-list extended SPRINT-CDMA-1-ACL" "no permit ip any 10.160.0.0 0.0.31.255" "ip access-list extended SPRINT-CDMA-2-ACL" "20 permit ip any 10.160.0.0 0.0.31.255"
	puts "Proxy ACL has been modified to send traffic to .254"
}

# Write current nexthop ip address to a file
set filename "ipaddress.txt"
# open filename for writing
set fileId [open $filename "w"]
# Write current nexthop ip address to file
puts -nonewline $fileId $nexthop
# close filename after writing
close $fileId
puts "ipaddress.txt file was updated"
}
