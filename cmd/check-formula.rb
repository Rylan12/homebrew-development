# frozen_string_literal: true

module Homebrew
  module_function

  def check_formula_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `check-formula` [<options>] <formula>

        Run the various checks needed on <formula> before opening a PR in the Homebrew/homebrew-core repository.
      EOS
      switch      "-f", "--fix",
                  description: "Pass the `--fix` option to `brew style`."
      switch      "--skip-style",
                  description: "Don't run `brew style`."
      switch      "--skip-test",
                  description: "Don't run `brew test`."
      switch      "--skip-audit",
                  description: "Don't run `brew audit`."
      comma_array "--audit-flags=",
                  description: "Flags to pass to `brew audit`. Options are `strict`, `online`, `git`, or `new`."
      switch      "--continue-on-failure",
                  description: "Run all checks instead of exiting if a single check fails."
      switch      "-k", "--keep-formula",
                  description: "Don't uninstall <formula> when checks are finished. This is the default " \
                               "if <formula> was not installed before running the checks."
      switch      "-u", "--uninstall-dependencies",
                  description: "Uninstall the unused dependencies of <formula> when checks are finished."

      conflicts "fix", "skip-style"
      conflicts "audit-flags", "skip-audit"
      conflicts "keep-formula", "uninstall-dependencies"

      named :formula
    end
  end

  def check_formula
    args = check_formula_args.parse

    formula = args.named.to_formulae.first

    if args.audit_flags&.any? { |flag| %w[strict online git new].exclude?(flag) }
      raise ArgumentError, "audit-flags must only contain `strict`, `online`, `git`, and/or `new`."
    end

    formula_installed = formula.any_version_installed?

    require_relative "../lib/check"

    # As this command is simplifying user-run commands then let's just use a
    # user path, too.
    ENV["PATH"] = ENV["HOMEBREW_PATH"]

    failures = []
    continue = true
    uninstall_formula = !formula_installed && !args.keep_formula?

    # uninstall formula if needed
    if formula_installed
      Check.run_brew_command %W[uninstall --ignore-dependencies #{formula.name}], exit_on_failure: true
    end

    # brew style <formula>
    style_command = %w[style --display-cop-names]
    style_command << "--fix" if args.fix?
    style_command << formula.name
    if !args.skip_style? && !Check.run_brew_command(style_command)
      continue = false unless args.continue_on_failure?
      failures << style_command
    end

    # brew install --only-dependencies <formula>
    install_deps_command = %W[install --only-dependencies #{formula.name}]
    if continue && !Check.run_brew_command(install_deps_command)
      continue = false
      uninstall_formula = false
      failures << install_deps_command
    end

    # brew install --build-from-source <formula>
    install_command = %W[install --build-from-source #{formula.name}]
    if continue && !Check.run_brew_command(install_command)
      continue = false
      uninstall_formula = false
      failures << install_command
    end

    # brew test <formula>
    test_command = %W[test #{formula.name}]
    if continue && !args.skip_test? && !Check.run_brew_command(test_command)
      continue = false unless args.continue_on_failure?
      failures << test_command
    end

    # brew audit <formula>
    audit_command = %w[audit --skip-style]
    audit_command += args.audit_flags&.map { |flag| "--#{flag}" } || %w[--strict --online --git]
    audit_command << formula.name
    if continue && !args.skip_audit? && !Check.run_brew_command(audit_command)
      continue = false unless args.continue_on_failure?
      failures << audit_command
    end

    if !continue && (uninstall_formula || args.uninstall_dependencies?)
      puts Formatter.headline("Cleaning Up!", color: :red)
      puts
    end

    # brew uninstall <formula>
    uninstall_command = %W[uninstall #{formula.name}]
    if uninstall_formula && formula.any_version_installed? && !Check.run_brew_command(uninstall_command)
      failures << uninstall_command
    end

    # brew uninstall <formula-deps>
    if args.uninstall_dependencies?
      formula_deps = formula.deps.map(&:name)
      uninstall_formula_deps_command = %w[uninstall]
      uninstall_formula_deps_command += removable_formulae.map(&:name) & formula_deps
      if uninstall_formula_deps_command.count > 1 &&
         !Check.run_brew_command(uninstall_formula_deps_command)
        failures << uninstall_formula_deps_command
      end
    end

    if failures.empty?
      oh1 "Success!"
      return
    end

    Check.display_failure_message failures
    Homebrew.failed = true
  end

  def removable_formulae(formulae = Formula.installed)
    removable = Formula.installed_formulae_with_no_dependents(formulae).reject do |f|
      Tab.for_keg(f.any_installed_keg).installed_on_request
    end

    removable += removable_formulae(formulae - removable) if removable.present?

    removable
  end
end
