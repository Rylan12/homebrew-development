# frozen_string_literal: true

module Homebrew
  module_function

  DEFAULT_HIDDEN_TAP_LOCATION = (HOMEBREW_PREFIX/".hidden-taps").freeze
  HOMEBREW_TAP_LIBRARY = (HOMEBREW_LIBRARY/"Taps/homebrew").freeze

  def move_core_cask_args
    Homebrew::CLI::Parser.new do
      description <<~EOS
        Move the `homebrew/core` and `homebrew/cask` taps into and out of `$HOMEBREW_LIBRARY/Taps`
        for API testing purposes.

        If `--tap` or `--untap` are specified, the taps will be tapped or untapped, respectively.
        If they are already in the appropriate location, they will be skipped. Otherwise, they will
        toggle between being tapped and untapped (based on `homebrew/core`, if it exists).

        If no location is specified with the `--location` flag, the taps will be moved into
        `$HOMEBREW_PREFIX/.hidden-taps`.
      EOS
      switch      "-t", "--tap",
                  description: "Move the taps into the tap library."
      switch      "-u", "--untap",
                  description: "Move the taps out of the tap library."
      switch      "--core-only",
                  description: "Only move the `homebrew/core` tap."
      switch      "--cask-only",
                  description: "Only move the `homebrew/cask` tap."
      switch      "-s", "--status",
                  description: "Print the current status of the taps."
      flag        "-l", "--location=",
                  description: "The location to move the taps to when removing them from the tap library " \
                               "(default: `$HOMEBREW_PREFIX/.hidden-taps`)."

      conflicts "tap", "untap"
      conflicts "core-only", "cask-only"

      named_args :none
    end
  end

  def move_core_cask
    args = move_core_cask_args.parse

    hidden_tap_location = args.location || DEFAULT_HIDDEN_TAP_LOCATION
    FileUtils.mkdir_p hidden_tap_location unless hidden_tap_location.directory?

    taps = []
    taps << CoreTap.instance unless args.cask_only?
    taps << CoreCaskTap.instance unless args.core_only?

    source_dir, target_dir, action_str = if args.tap? || (!args.untap? && !taps.first.path.exist?)
      odebug "Tapping #{taps.to_sentence}..."
      [hidden_tap_location, HOMEBREW_TAP_LIBRARY, "Tapped"]
    else
      odebug "Untapping #{taps.to_sentence}..."
      [HOMEBREW_TAP_LIBRARY, hidden_tap_location, "Untapped"]
    end

    moved_taps = []

    taps.each do |tap|
      tap_basename = tap.path.basename

      if args.status?
        if (HOMEBREW_TAP_LIBRARY/tap_basename).exist?
          puts "#{tap} is tapped"
        else
          puts "#{tap} is untapped"
        end
        next
      end

      if (target_dir/tap_basename).exist?
        opoo "#{tap} is already in #{target_dir}"
        next
      end
      unless (source_dir/tap_basename).exist?
        opoo "#{tap} is not in #{source_dir}"
        next
      end

      odebug "Moving #{tap} from #{source_dir} to #{target_dir}"
      FileUtils.move source_dir/tap_basename, target_dir
      moved_taps << tap
    end
    puts "#{action_str} #{moved_taps.to_sentence}" unless moved_taps.empty?
  end
end
