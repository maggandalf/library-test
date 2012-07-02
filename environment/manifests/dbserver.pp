group { 'puppet': ensure => 'present' }


class mysql_5 {
  
  package { "mysql-server-5.1":
    ensure => present
  }
  
  service { "mysql":
    ensure => running, 
    require => Package["mysql-server-5.1"]
  }



file { "/etc/mysql/my.cnf":
    owner => 'root',
    group => 'root',
    mode => 644,
    notify => Service['mysql'],
    source => '/vagrant/files/my.cnf',
    require => Package["mysql-server-5.1"],
  }

  exec { "create-db-schema":
    command => "/usr/bin/mysql -u root -p -e \"drop database if exists library;create database library;\"",
    require => Service["mysql"]
  }

 exec { "grant-library-schema-db":
	unless => "/usr/bin/mysql -umysql -pmysql library",
        command => "/usr/bin/mysql -uroot -e \"CREATE USER 'mysql'@'%' IDENTIFIED BY 'mysql';GRANT ALL ON library.* TO 'mysql'@'%';\"",
        require => [Service["mysql"], Exec["create-db-schema"]]
      }

}

exec { 'apt-get update':
  command => '/usr/bin/apt-get update'
}

include mysql_5
