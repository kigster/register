require 'register/version'
require 'colored2'
require 'forwardable'

# **Register** is a tiny library that can be included in a module
# that is to become a Façade to several application globals via
# auto-generated module-level methods.
#
# A good example is a register of several connections to either
# *Redis* or  *MemCached*, for example you might have a short-term
# memcached connection with a short default expiration TTL, and a
# longer-living one that requires sweeping to clean. You could
# use `Register` to wrap access to these singletons in
# `MyModule.cache_type` accessors.
#
# Usage
# =====
#
# To create a register module, just include `Register` in any
# of your custom ruby modules:
#
#         require 'register'
#
#         module Cache
#           include Register
#         end
#
#         Cache.register :rails, Rails.cache
#         Cache.register :durable, ActiveSupport::Cache::DalliStore.new(
#           ENV['MEMCACHED_HOSTS'] ? ENV['MEMCACHED_HOSTS'].split(',') : %w[localhost:11211],
#           namespace:      'v1',
#           socket_timeout: 0.2,
#           expires_in:     0, # never expire
#           keepalive:      true,
#           compress:       true,
#           failover:       true
#         )
#
#         Cache.rails # => Rails.cache
#         Cache.durable # => DalliStore, etc.
#
module Register
  class RegisterError < StandardError; end
  class AlreadyRegisteredError < RegisterError; end
  class NoSuchIdentifierError < RegisterError; end
  class ReservedIdentifierError < RegisterError; end

  RESERVED = (Register.methods + %i[for register keys values << add_method]).flatten.uniq.freeze

  def self.included(klass)
    klass.instance_eval do
      @store = Hash.new
      @mutex = Mutex.new
      class << self
        extend Forwardable
        def_delegators :@store, :keys
        attr_accessor :mutex

        def << *names, **opts, &block
          names.flatten!
          item = block ? yield(self) : names.pop
          validate_reserved_keys!(names)
          @mutex.synchronize do
            validate_existing_keys!(names, opts)
            names.each do |n|
              store[n] = item
              add_method(n)
            end
          end
          item
        end

        alias register <<

        def for(id)
          unless store.key?(id)
            raise NoSuchIdentifierError,
                  "No identifier #{id} found in the registry"
          end
          store[id]
        end

        def values
          store.values.uniq
        end

        private

        def store
          @store
        end

        def add_method(id)
          return unless id.is_a?(Symbol)
          unless self.respond_to?(id)
            line_no     = __LINE__
            method_defs = %Q!
              def self.#{id}
                store[:#{id}]
              end\n!
            module_eval method_defs, __FILE__, line_no
          end
        end

        def validate_reserved_keys!(names)
          reserved = names.select { |n| RESERVED.include?(n) }
          unless reserved.empty?
            raise ReservedIdentifierError, "The following keys are reserved and can not be used: #{reserved}"
          end
        end

        def validate_existing_keys!(names, opts = {})
          already = names.select { |n| store.key?(n) }
          if !already.empty? && opts[:ignore_if_exists].nil?
            raise AlreadyRegisteredError, "The following keys are already in the registry: #{already}"
          end
        end
      end
    end
  end
end

