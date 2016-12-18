class HashSerializer
  def self.dump(hash)
    hash.to_json
  end

  def self.load(hash)
    hash = {} if hash.eql?('{}')
    (hash || {}).with_indifferent_access
  end
end
