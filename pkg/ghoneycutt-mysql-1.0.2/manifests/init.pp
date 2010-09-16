# Class: mysql
#
# This module manages mysql clients and provides tools for dealing with mysql
#
# Requires:
#   class puppet
#   $lsbProvider is set in site manifest
#
class mysql {

    include puppet

    $snippets = "/opt/$lsbProvider/mysql_snippets"

    file { "$snippets":
        ensure => directory,
        mode   => "700",
    } # file

    package { "mysql": }

    # Definition: mysql::do
    #
    # connect to a mysql host and run specified sql code
    #
    # Parameters:   
    #   $host     - hostname, uses localhost by default
    #   $port     - port number, uses 3306 by default
    #   $content  - specify content or a template instead of a .sql file
    #   $source   - .sql file to load
    #   $user     - mysql username, uses root by default
    #   $password - mysql password uses blank by default
    #   $database - name of mysql database
    #
    # Actions:
    #   connects to a mysql host and load sql code
    #
    # Requires:
    #   must specify at least $source or $content
    #
    # Sample Usage:
    #    # setup database 
    #    mysql::do {
    #        "openfire_db_create":
    #            source  => "puppet:///modules/openfire/openfire.sql";
    #        "openfire_db_setup":
    #            require => Mysql::Do["openfire_db_create"],
    #            database => "$openfireDB",
    #            source  => "puppet:///modules/openfire/openfire_mysql.sql";
    #    } # mysql::do
    #
    define do ($host = localhost, $port = undef, $content = '', $source = '', $user = "root", $password = '', $database = '') {
        # if port is unspecified, use 3306
        if $port{
            $myport = $port
        } else {
            $myport = "3306"
        } # fi $port

        file { 
            "${mysql::snippets}/$name.sql":
                mode   => "600";
        } # file
        
        exec { "mysql-do-$name":
            creates => "${puppet::semaphores}/$name.mysql",
        } # exec

        case $content {
            '': {
                File["${mysql::snippets}/$name.sql"] {
                    source => "$source",
                } # File
            } # '' empty
            default: {
                File["${mysql::snippets}/$name.sql"] {
                    content => "$content",
                } # File
            } # default
        } # case $content
        
        case $password {
            '': {
                Exec["mysql-do-$name"] {
                    command +> "mysql -u$user -h$host -P$myport $database < ${mysql::snippets}/$name.sql > ${puppet::semaphores}/$name.mysql"
                } # Exec
            } # '' empty
            default: {
                Exec["mysql-do-$name"] {
                    command +> "mysql -u$user -h$host -P$myport -p$password $database < ${mysql::snippets}/$name.sql > ${puppet::semaphores}/$name.mysql",
                } # Exec
            } # default
        } # case $password

        case $host {
            default: {
                Exec["mysql-do-$name"] {
                    require +> [ File["${mysql::snippets}/$name.sql"], File["${puppet::semaphores}"] ],
                } # Exec
            } # default
            localhost: {
                Exec["mysql-do-$name"] {
                    require +> [ File["${mysql::snippets}/$name.sql"], File["${puppet::semaphores}"] ],
                    #before  +> Exec["MySQL flush privileges"],
                } # Exec
            } # localhost
        } # case $host
    } # define do
} # class mysql
