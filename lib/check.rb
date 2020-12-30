# frozen_string_literal: true

require "english"

module Check
  module_function

  def run_brew_command(command, exit_on_failure: false, failures: [])
    ohai "brew #{command.join(" ")}"

    system HOMEBREW_BREW_FILE, *command

    if $CHILD_STATUS.success?
      puts
      return true
    end

    if exit_on_failure
      display_failure_message(failures + [command])
      exit 1
    else
      onoe "`brew #{command.join(" ")}` failed!"
      puts
      false
    end
  end

  def display_failure_message(failures)
    puts <<~MESSAGE
      #{Formatter.headline("Failure!", color: :red)}
      The following #{"command".pluralize failures.count} failed:
        #{failures.map { |command| "brew #{command.join(" ")}" }.join("\n  ")}
    MESSAGE
  end
end
