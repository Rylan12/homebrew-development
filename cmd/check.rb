# frozen_string_literal: true

module Homebrew
  module_function

  def check_args
    Homebrew::CLI::Parser.new do
      description <<~EOS
        Run the various checks needed before opening a PR in the Homebrew/brew repository.
      EOS
      switch      "-t", "--tests",
                  description: "Run `brew tests`."
      switch      "-f", "--fix",
                  description: "Pass the `--fix` option to `brew style`."
      switch      "--exit-on-failure",
                  description: "Exit if a single check fails instead of running all checks."
      flag        "--only=",
                  description: "Run only the specified command. Options are `style`, `vale`, `typecheck`, " \
                               "`generate-man-completions`, or `tests`."
      comma_array "--except=",
                  description: "Don't run the specified checks. Options are `style`, `vale`, `typecheck`, " \
                               "or `generate-man-completions`."

      conflicts "only", "except"

      named_args :none
    end
  end

  def check
    args = check_args.parse

    if args.only && %w[style vale typecheck generate-man-completions tests].exclude?(args.only)
      raise ArgumentError,
            "`--only` must be either `style`, `vale`, `typecheck`, `generate-man-completions`, or `tests`."
    end

    if args.except&.any? { |check| %w[style vale typecheck generate-man-completions].exclude?(check) }
      raise ArgumentError,
            "`--except` must only contain `style`, `vale`, `typecheck`, and/or `generate-man-completions`."
    end

    run_style = run_check?("style", args: args)
    run_vale = run_check?("vale", args: args)
    run_typecheck = run_check?("typecheck", args: args)
    run_man = run_check?("generate-man-completions", args: args)
    run_tests = args.tests? || run_check?("tests", args: args, default: false)

    raise ArgumentError, "`--fix` cannot be passed unless style checks are being run." if !run_style && args.fix?

    require_relative "../lib/check"

    # As this command is simplifying user-run commands then let's just use a
    # user path, too.
    ENV["PATH"] = ENV.fetch("HOMEBREW_PATH", nil)

    failures = []

    style_command = %w[style --display-cop-names]
    style_command << "--fix" if args.fix?
    if run_style && !Check.run_brew_command(style_command, exit_on_failure: args.exit_on_failure?)
      failures << style_command
    end

    vale_command = %W[vale --config #{HOMEBREW_REPOSITORY}/.vale.ini #{HOMEBREW_REPOSITORY}/docs/]
    if run_vale && !Check.run_shell_command(vale_command, exit_on_failure: args.exit_on_failure?)
      failures << vale_command
    end

    typecheck_command = %w[typecheck]
    if run_typecheck && !Check.run_brew_command(typecheck_command, exit_on_failure: args.exit_on_failure?)
      failures << typecheck_command
    end

    man_command = %w[generate-man-completions]
    Check.run_brew_command(man_command, ignore_failure: true) if run_man

    tests_command = %w[tests]
    if run_tests && !Check.run_brew_command(tests_command, exit_on_failure: args.exit_on_failure?)
      failures << tests_command
    end

    if failures.empty?
      oh1 "Success!"
      return
    end

    Check.display_failure_message failures
    Homebrew.failed = true
  end

  def run_check?(check, args:, default: true)
    if args.except&.any?(check) ||
       (args.only && args.only != check)
      false
    else
      default
    end
  end
end
