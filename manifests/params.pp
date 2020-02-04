# == Class: hadoop::params

class hadoop::params {

    $datanode_service_enable = false

    # datanodes with less than 70GB RAM get 1024MB heap by default
    # datanodes with more get 4096MB heap by default
    if $facts['memory']['system']['total_bytes'] < 75161927680 {
        $datanode_heap_size = 1024
    }
    else {
        $datanode_heap_size = 4096
    }

    $ganglia_udp_send_channel = undef
    $namenode_service_enable = false

}
