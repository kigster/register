require 'register'

module Cache
  include Register
end

CacheStore = Struct.new(:name)

Cache.register %i[planetary], CacheStore.new(:saturn)

Cache.<< %i[primary main rails deploy] << CacheStore.new(:primary)

Cache.<< %i[durable secondary] << CacheStore.new(:secondary)



