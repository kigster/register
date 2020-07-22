# frozen_string_literal: true

require 'register'

module Cache
  include Register
end

CacheStore = Struct.new(:name)
