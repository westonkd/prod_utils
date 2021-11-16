module ProdUtils::Database
  REGION_MAP = {
    'eu-west-1' => 'dub',
    'eu-central-1' => 'fra',
    'us-east-1' => 'iad',
    'us-west-2' => 'pdx',
    'ap-southeast-1' => 'sin',
    'ap-southeast-2' => 'syd',
    'ca-central-1' => 'yul',
  }

  def self.region_for(shard)
    shard.database_server.config[:region]
  end

  def self.hosts_for(shard)
    hosts = []
    shard.activate do
      Account.root_accounts
        .preload(:account_domains)
        .each { |ra| ra.account_domains.each { |ad| hosts << ad.host } }
    end
    hosts.flatten
  end

  def self.hosts_for_cluster(cluster)
    hosts = []
    Shard.where(
      database_server_id: "cluster#{cluster}"
    ).map do |shard|
      hosts << hosts_for(shard)
    end
    hosts
  end
end
