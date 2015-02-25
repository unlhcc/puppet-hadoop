
# Class: hadoop
#
# HDFS module for use at Holland Computing Center
#
# Parameters:
#
# [*datanode_service_enable*]
#   Whether to enable the datanode service. Defaults to true.
#
# [*ganglia_udp_send_channel*]
#   Array of [hostname, port] defining where to send ganglia metrics.
#
# [*namenode_service_enable*]
#   Whether to enable the namenode service. Defaults to false.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class hadoop (
    $datanode_service_enable  = $hadoop::params::datanode_service_enable,
    $ganglia_udp_send_channel = $hadoop::params::ganglia_udp_send_channel,
    $namenode_service_enable  = $hadoop::params::namenode_service_enable,
    ) inherits hadoop::params {

    validate_bool($datanode_service_enable)
    validate_array($ganglia_udp_send_channel)
    validate_bool($namenode_service_enable)

    package { 'hadoop':
        ensure => 'present',
    }

    package { 'hadoop-libhdfs':
        ensure => present,
        name   => 'hadoop-libhdfs',
    }

    package { 'hadoop-client':
        ensure => present,
        name   => 'hadoop-client',
    }

    package { 'hadoop-fuse':
        ensure  => present,
        name    => 'hadoop-hdfs-fuse',
        require => Package['hadoop'],
    }

    # ensure /hadoop-data* directories are owned by hdfs:hadoop
    # should only do this once, but every time won't hurt
    exec { 'chown hdfs:hadoop /hadoop-data*':
        path   => '/usr/bin:/usr/sbin:/bin',
        onlyif => [ 'test `ls -ld /hadoop-data1 | awk "{print \$3}""` != hdfs' ],
    }

    # we keep our configs on a dedicated conf.red directory
    # start by cleaning and copying default configs
    file { '/etc/hadoop/conf.red':
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => 'puppet:///modules/hadoop/defaults',
        require => Package['hadoop'],
    }

    # now apply our custom configs
    file { '/etc/hadoop/conf.red/hdfs-site.xml':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('hadoop/hdfs-site.xml.erb'),
        require => Package['hadoop'],
    }

    file { '/etc/hadoop/conf.red/core-site.xml':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('hadoop/core-site.xml.erb'),
        require => Package['hadoop'],
    }

    file { '/etc/hadoop/conf.red/hadoop-metrics.properties':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('hadoop/hadoop-metrics.properties.erb'),
        require => Package['hadoop'],
    }

    file { '/etc/hadoop/conf.red/hadoop-metrics2.properties':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('hadoop/hadoop-metrics2.properties.erb'),
        require => Package['hadoop'],
    }

    file { '/etc/hadoop/conf.red/hadoop-env.sh':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('hadoop/hadoop-env.sh.erb'),
        require => Package['hadoop'],
    }

    file { '/etc/hadoop/conf.red/log4j.properties':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('hadoop/log4j.properties.erb'),
        require => Package['hadoop'],
    }

    file { '/etc/hadoop/conf.red/mapred-site.xml':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('hadoop/mapred-site.xml.erb'),
        require => Package['hadoop'],
    }

    file { '/etc/hadoop/conf.red/rack_mapfile.txt':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => 'puppet:///modules/hadoop/rack_mapfile.txt',
        require => Package['hadoop'],
    }

    file { '/etc/hadoop/conf.red/rackmap.pl':
        owner   => 'hdfs',
        group   => 'root',
        mode    => '0744',
        source  => 'puppet:///modules/hadoop/rackmap.pl',
        require => Package['hadoop'],
    }


    # ALTERNATIVES maintenance
    # we use the alternatives system to keep our hadoop configs in a dedicated
    # location called conf.red (as opposed to conf.osg from the -osg RPMs)

    # check if alternatives currently points at our configs and fix if not
    exec { 'run_hadoop_conf_alt_install':
        path      => '/usr/bin:/usr/sbin:/bin',
        command   => '/usr/sbin/alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.red 50',
        unless    => '/usr/bin/test `/bin/ls -l /etc/alternatives/hadoop-conf | /bin/awk "{print \$11}"` = /etc/hadoop/conf.red',
        logoutput => true,
        require   => Package['hadoop'],
    }

    exec { 'run_hadoop_conf_alt_link':
        path      => '/usr/bin:/usr/sbin:/bin',
        command   => '/usr/sbin/alternatives --auto hadoop-conf',
        unless    => '/usr/bin/test `/bin/ls -l /etc/alternatives/hadoop-conf | /bin/awk "{print \$11}"` = /etc/hadoop/conf.red',
        logoutput => true,
        require   => Package['hadoop'],
    }


    # isHDFSDatanode
    if $datanode_service_enable {
        package { 'hadoop-datanode':
            ensure  => present,
            name    => 'hadoop-hdfs-datanode',
            require => Package['hadoop'],
        }

        file { 'hdfs-log-rotate':
            path    => '/usr/local/sbin/hdfs-log-rotate',
            owner   => 'root',
            group   => 'root',
            mode    => '0744',
            source  => 'puppet:///modules/hadoop/hdfs-log-rotate',
            require => Package['hadoop'],
        }

        cron { 'hdfs-log-rotate':
            ensure  => present,
            command => '/usr/local/sbin/hdfs-log-rotate',
            user    => 'root',
            minute  => '45',
            hour    => '4',
            require => File['hdfs-log-rotate'],
        }
    } # isHDFSDatanode

    # Limits.conf for name node. Needed for other?
    if $namenode_service_enable {
        file { 'limits.conf':
            path    => '/etc/security/limits.conf',
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            source  => 'puppet:///modules/hadoop/limits-name.conf',
            require => Package['hadoop'],
        }

        file { '99-hdfs-limits.conf':
            path    => '/etc/security/limits.d/99-hdfs-limits.conf',
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            source  => 'puppet:///modules/hadoop/99-hdfs-limits.conf',
            require => Package['hadoop'],
        }
    }
}
