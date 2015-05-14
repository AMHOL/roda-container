class Roda
  ContainerError = Class.new(::Exception)

  module RodaPlugins
    # The container plugin allows your application to
    # act as a container, you can register values
    # with your application (container) and resolve them later.
    #
    # If you register something that responds to call, the result of
    # call will be returned each time you resolve it.
    #
    # Example:
    #
    #   plugin :container
    #
    #   class UserRepository
    #     def self.first
    #       { name: 'Jack' }
    #     end
    #   end
    #
    #   MyApplication.register(:user_repository, UserRepository)
    #   MyApplication.resolve(:user_repository).first
    #
    #   class PersonRepository
    #     def first
    #       { name: 'Gill' }
    #     end
    #   end
    #
    #   MyApplication.register(:person_repository, -> { PersonRepository.new })
    #   MyApplication.resolve(:person_repository).first
    module Container
      class Content
        attr_reader :item, :options

        def initialize(item, options = {})
          @item, @options = item, {
            call: item.kind_of?(::Proc)
          }.merge(options)
        end

        def call?
          options[:call] == true
        end
      end

      module ClassMethods
        # Whether middleware from the current class should be inherited by subclasses.
        # True by default, should be set to false when using a design where the parent
        # class accepts requests and uses run to dispatch the request to a subclass.
        attr_reader :container
        private :container

        def self.extended(subclass)
          subclass.instance_variable_set(:@container, RodaCache.new)
          super
        end

        def inherited(subclass)
          subclass.instance_variable_set(:@container, container)
          super
        end

        def register(key, contents = nil, options = {}, &block)
          if block_given?
            item = block
            options = contents if contents.is_a?(::Hash)
          else
            item = contents
          end
          container[key] = Roda::RodaPlugins::Container::Content.new(item, options)
        end

        def resolve(key)
          content = container.fetch(key) do
            fail ::Roda::ContainerError, "Nothing registered with the name #{key}"
          end

          if content.call?
            content.item.call
          else
            content.item
          end
        end

        def detach_container
          @container = container.dup
        end

        def freeze
          container.freeze
          super
        end
      end
    end

    register_plugin(:container, Container)
  end
end
