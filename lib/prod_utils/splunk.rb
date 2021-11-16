module ProdUtils::Splunk
  def self.base_query(region)
    "index=canvas_#{ProdUtils::Database::REGION_MAP[region]} "
  end

  def self.slow_requests_for_hosts(hosts, region: 'us-east-1')
    query = base_query(region)
    hosts.each_with_index { |host, i| query << "#{i == 0 ? '' : 'OR '}vhost=#{host} " }
    query << " | where microseconds < 5000000 | sort microseconds desc"
    query
  end

  def self.slow_requests_for_cluster(cluster)
    region = Shard.where(
      database_server_id: "cluster#{cluster}"
    ).limit(1).first.database_server.config[:region]

    "#{base_query(region)}cluster=cluster#{cluster} | where microseconds < 5000000 | sort microseconds desc"
  end

  def self.slow_requests_for_shard(shard_id)
    shard = Shard.find shard_id

    slow_requests_for_hosts(
      ProdUtils::Database.hosts_for(shard),
      region: ProdUtils::Database.region_for(shard)
    )
  end
end
