# frozen_string_literal: true

require "english"

module Check
  module_function

  def run_brew_command(command, exit_on_failure: false, failures: [])
    command = [HOMEBREW_BREW_FILE.to_s, *command]
    run_shell_command command, exit_on_failure: exit_on_failure, failures: failures
  end

  def run_shell_command(command, exit_on_failure: false, failures: [])
    command_string = "#{File.basename(command[0])} #{command[1..].join(" ")}"
    ohai command_string

    system(*command)

    if $CHILD_STATUS.success?
      puts
      return true
    end

    if exit_on_failure
      display_failure_message(failures + [command_string])
      exit 1
    else
      onoe "`#{command_string}` failed!"
      puts
      false
    end
  end

  def display_failure_message(failures)
    formatted_failures = failures.map do |command|
      next command if command.is_a? String

      command.join(" ")
    end

    puts <<~MESSAGE
      #{Formatter.headline("Failure!", color: :red)}
      The following #{"command".pluralize failures.count} failed:
        #{formatted_failures.join("\n  ")}
    MESSAGE
  end
end
