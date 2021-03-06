module ThreeScaleToolbox
  module Commands
    module MethodsCommand
      module Create
        class CustomPrinter
          attr_reader :option_disabled

          def initialize(options)
            @option_disabled = options[:disabled]
          end

          def print_record(method)
            puts "Created method id: #{method['id']}. Disabled: #{option_disabled}"
          end

          def print_collection(collection) end
        end

        class CreateSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'create'
              usage       'create [opts] <remote> <service> <method-name>'
              summary     'create method'
              description 'Create method'

              option      :t, 'system-name', 'Method system name', argument: :required
              flag        nil, :disabled, 'Disables this method in all application plans'
              option      nil, :description, 'Method description', argument: :required
              ThreeScaleToolbox::CLI.output_flag(self)

              param       :remote
              param       :service_ref
              param       :method_name

              runner CreateSubcommand
            end
          end

          def run
            hits = service.hits
            method = ThreeScaleToolbox::Entities::Method.create(
              service: service,
              parent_id: hits.fetch('id'),
              attrs: method_attrs
            )
            method.disable if option_disabled

            printer.print_record method.attrs
          end

          private

          def method_attrs
            {
              'system_name' => options[:'system-name'],
              'friendly_name' => arguments[:method_name],
              'description' => options[:description]
            }.compact
          end

          def option_disabled
            options.fetch(:disabled, false)
          end

          def service
            @service ||= find_service
          end

          def find_service
            Entities::Service.find(remote: remote,
                                   ref: service_ref).tap do |svc|
              raise ThreeScaleToolbox::Error, "Service #{service_ref} does not exist" if svc.nil?
            end
          end

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def service_ref
            arguments[:service_ref]
          end

          def printer
            # keep backwards compatibility
            options.fetch(:output, CustomPrinter.new(disabled: option_disabled))
          end
        end
      end
    end
  end
end
