require 'register/version'
require 'colored2'
module Register
  class AlreadyRegisteredError < StandardError;
  end
  class NoSuchIdentifierError < StandardError;
  end

  def self.included(klass)
    klass.instance_eval do
      @store = Hash.new
      @mutex = Mutex.new
      class << self
        attr_accessor :store, :mutex

        def <<(*names, &block)
          names.flatten!
          item    = block ? yield(self) : names.pop
          already = names.select { |n| store.key?(n) }
          unless already.empty?
            raise AlreadyRegisteredError, "The following keys are already in the registry: #{already}"
          end
          names.each do |n|
            store[n] = item
            add_method(n)
          end
        end

        alias register <<

        def for(id)
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
      end
    end
  end
end

