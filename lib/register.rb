require 'register/version'
require 'colored2'
module Register
  class RegisterError < StandardError; end
  class AlreadyRegisteredError < RegisterError; end
  class NoSuchIdentifierError < RegisterError; end
  class ReservedIdentifierError < RegisterError; end

  module DummyModule
  end

  RESERVED = (DummyModule.methods << %i[for register << add_method]).flatten!.freeze

  def self.included(klass)
    klass.instance_eval do
      @store = Hash.new
      @mutex = Mutex.new
      class << self
        attr_accessor :store, :mutex
        def <<(*names, &block)
          names.flatten!
          item = block ? yield(self) : names.pop
          validate_existing_keys!(names)
          validate_reserved_keys!(names)
          names.each do |n|
            store[n] = item
            add_method(n)
          end
        end

        alias register <<

        def for(id)
          unless store.key?(id)
            raise NoSuchIdentifierError,
                  "No identifier #{id} found in the registry"
          end
          store[id]
        end

        private

        def add_method(id)
          return unless id.is_a?(Symbol)
          @mutex.synchronize do
            unless self.respond_to?(id)
              line_no     = __LINE__
              method_defs = %Q!
              def self.#{id}
                store[:#{id}]
              end\n!
              module_eval method_defs, __FILE__, line_no
            end
          end
        end

        def validate_reserved_keys!(names)
          reserved = names.select { |n| RESERVED.include?(n) }
          unless reserved.empty?
            raise ReservedIdentifierError, "The following keys are reserved and can not be used: #{reserved}"
          end
        end

        def validate_existing_keys!(names)
          already = names.select { |n| store.key?(n) }
          unless already.empty?
            raise AlreadyRegisteredError, "The following keys are already in the registry: #{already}"
          end
        end


      end
    end
  end
end

