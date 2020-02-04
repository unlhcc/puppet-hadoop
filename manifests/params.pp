# == Class: hadoop::params

class hadoop::params {

    $datanode_service_enable = false
    $datanode_heap_size = 1024
    $ganglia_udp_send_channel = undef
    $namenode_service_enable = false

}
