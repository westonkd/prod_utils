require_relative "prod_utils/version"
require_relative "prod_utils/splunk"
require_relative "prod_utils/database"

module ProdUtils
  def self.ll
    [ProdUtils::Database, ProdUtils::Splunk].each do |mod|
      puts "=== #{mod} ==="
      puts mod.methods(false).join("\n")
      puts ''
    end
  end
end
