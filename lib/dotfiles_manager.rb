require 'fileutils'
require 'shellwords'

class DotfilesManager

  PATH = File.expand_path('~/.config/dotfiles-manager')

  attr_reader :config

  def initialize(config, options = {})
    @config = config
    @options = options
  end

  def run(command, *arguments)
    shell_command =
      ([command] + arguments).
      collect() { |arg| Shellwords.escape(arg) }.
      join(' ')

    if @options[:verbose]
      puts(shell_command)
    end

    result = `#{shell_command}`
    if $?.exitstatus != 0
      raise "Failed to execute command #{shell_command}"
    end

    return result
  end

  def pull(options = [])
    @config.get(:synchronize).each() { |entry|
      entry = entry.clone()
      on_command = entry.delete(:on_command)
      if !on_command.nil?() && on_command != 'pull'
        next
      end

      command = DotfilesManager::Utility.get_command_instance(self, entry)
      command.pull(options)
    }
  end

  def push(options = [])
    @config.get(:synchronize).each() { |entry|
      entry = entry.clone()
      on_command = entry.delete(:on_command)
      if !on_command.nil?() && on_command != 'push'
        next
      end

      command = DotfilesManager::Utility.get_command_instance(self, entry)
      command.push(options)
    }
  end

end

require 'dotfiles_manager/config.rb'
require 'dotfiles_manager/utility.rb'

require 'dotfiles_manager/file.rb'
require 'dotfiles_manager/storage_git.rb'
require 'dotfiles_manager/package_pacman.rb'
require 'dotfiles_manager/package_yaourt.rb'