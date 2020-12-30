# frozen_string_literal: true

require "english"

module Homebrew
  module_function

  def check_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `check` [<options>]

        Run the various checks needed before opening a PR in the Homebrew/brew repository.
      EOS
      switch      "-t", "--tests",
                  description: "Run `brew tests`."
      switch      "-f", "--fix",
                  description: "Pass the `--fix` option to `brew style`."
      switch      "--exit-on-failure",
                  description: "Exit if a single check fails instead of running all checks."
      flag        "--only=",
                  description: "Run only the specified command. Options are `style`, `typecheck`, `man`, or `tests`."
      comma_array "--except=",
                  description: "Don't run the specified checks. Options are `style`, `typecheck`, or `man`."

      conflicts "only", "except"
    end
  end

  def check
    args = check_args.parse

    if args.only && %w[style typecheck man tests].exclude?(args.only)
      raise ArgumentError, "`--only` must be either `style`, `typecheck`, `man`, or `tests`."
    end

    if args.except&.any? { |check| %w[style typecheck man].exclude?(check) }
      raise ArgumentError, "`--except` must only contain `style`, `typecheck`, and/or `man`."
    end

    run_style = run_check?("style", args: args)
    run_typecheck = run_check?("typecheck", args: args)
    run_man = run_check?("man", args: args)
    run_tests = args.tests? || run_check?("tests", args: args, default: false)

    raise ArgumentError, "`--fix` cannot be passed unless style checks are being run." if !run_style && args.fix?

    # As this command is simplifying user-run commands then let's just use a
    # user path, too.
    ENV["PATH"] = ENV["HOMEBREW_PATH"]

    failures = []

    style_check = "style"
    style_check += " --fix" if args.fix?
    failures << style_check if run_style && !run_check(style_check, exit_on_failure: args.exit_on_failure?)

    failures << "typecheck" if run_typecheck && !run_check("typecheck", exit_on_failure: args.exit_on_failure?)

    failures << "man" if run_man && !run_check("man", exit_on_failure: args.exit_on_failure?)

    failures << "tests" if run_tests && !run_check("tests", exit_on_failure: args.exit_on_failure?)

    if failures.empty?
      oh1 "Success!"
      return
    end

    puts <<~MESSAGE
      #{Formatter.headline("Failure!", color: :red)}
      The following #{"command".pluralize failures.count} failed:
        #{failures.map { |command| "brew #{command}" }.join("\n")}
    MESSAGE
    Homebrew.failed = true
  end

  def run_check?(check, args:, default: true)
    if args.except&.any? { |except_check| except_check == check } ||
       args.only && args.only != check
      false
    else
      default
    end
  end

  def run_check(check, exit_on_failure: false)
    ohai "brew #{check}"

    system HOMEBREW_BREW_FILE, check

    if $CHILD_STATUS.success?
      puts
      return true
    end

    if exit_on_failure
      odie "`brew #{check}` failed!"
    else
      onoe "`brew #{check}` failed!"
      puts
      false
    end
  end
end
