# Class: mysql::server
#
# This module manages mysql servers
#
# Requires:
#   class mylvmbackup
#
# Sample Usage: include mysql::server
#
class mysql::server {

    include mylvmbackup
    include mysql

    package { "mysql-server": }
    
    # choose based on $fqdn first, then install a generic mysql config file
    file { "/etc/my.cnf":
        group   => "mysql",
        mode    => "640",
        notify  => Service["mysqld"],
        source  => [ "puppet:///modules/mysql/my.cnf-$fqdn", "puppet:///modules/mysql/my.cnf" ],
        require => Package["mysql-server"];
    } # file

    service {"mysqld":
        enable  => true,
        ensure  => running,
        require => Package["mysql-server"],
    } # service
} # class mysql::server
