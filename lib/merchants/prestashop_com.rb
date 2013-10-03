module PrestashopCom
  IDS = {
    "cadeau-maestro.com"=>165,
    "lageekerie.com"=>169,
    "nodshop.com"=>172,
    "lavantgardiste.com"=>179,
    "topgeek.net"=>188,
    "mycrazystuff.com"=>211,
    "prestashop.com"=>511
  }

  def self.getAllMappings
    maps = {}
    for site, id in IDS
      maps[site] = self.getMapping(id)
    end
    maps
  end

  def self.getMapping(id=511)
    puts "Going to *GET* mapping for #{IDS.key(id)}, id=#{id}..."
    http = Net::HTTP.new("www.shopelia.fr", 443)
    http.use_ssl = true
    resp = http.send_request('GET', "/api/viking/merchants/#{id}")
    JSON.parse resp.body
  end

  def self.putMapping(mapping, id=511)
    h = {"id" => id, "data" => { "viking" => {
          IDS.key(id) => (mapping["data"] && mapping["data"]["viking"] && 
            mapping["data"]["viking"].first && mapping["data"]["viking"].first.last) || mapping
        }}}
    puts "Going to *PUT* mapping for #{IDS.key(id)}, id=#{id}..."
    http = Net::HTTP.new("www.shopelia.fr", 443)
    http.use_ssl = true
    http.send_request('PUT', "/api/viking/merchants/#{id}", h.to_json, "Content-Type"=> "application/json")
  end

  def self.putAllMappings(mapping)
    for site, id in IDS
      self.putMapping(mapping, id)
    end
  end
end
