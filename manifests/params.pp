# == Class: hadoop::params

class hadoop::params {

    $datanode_service_enable = true
    $ganglia_udp_send_channel = undef
    $namenode_service_enable = false

}