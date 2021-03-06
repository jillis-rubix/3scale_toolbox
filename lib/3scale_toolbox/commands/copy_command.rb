require '3scale_toolbox/commands/copy_command/service_command'

module ThreeScaleToolbox
  module Commands
    module CopyCommand
      include ThreeScaleToolbox::Command
      def self.command
        Cri::Command.define do
          name        'copy'
          usage       'copy <sub-command> [options]'
          summary     'copy super command'
          description 'Copy 3scale entities between tenants'

          run do |_opts, _args, cmd|
            puts cmd.help
          end
        end
      end
      add_subcommand(ServiceSubcommand)
    end
  end
end
