require 'dry-container'

class Roda
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
      module_function

      def configure(app)
        app.send(:extend, Dry::Container::Mixin)
      end
    end

    register_plugin(:container, Container)
  end
end
