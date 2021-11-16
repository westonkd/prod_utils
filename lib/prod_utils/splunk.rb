module ProdUtils::Splunk
  def self.slow_requests_for_hosts(hosts, region: 'iad')
    query = "index=canvas_#{region} "
    hosts.each_with_index { |host, i| query << "#{i == 0 ? '' : 'OR '}vhost=#{host} " }
    query << " | where microseconds < 5000000 | sort microseconds desc"
    query
  end

  def self.slow_requests_for_cluster(cluster)
    region = Shard.where(
      database_server_id: "cluster#{cluster}"
    ).limit(1).first.database_server.config[:region]

    ProdUtils::Database.slow_requests_for_hosts(
      hosts_for_cluster(cluster),
      region: region_map[region]
    )
  end
end
