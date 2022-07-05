# frozen_string_literal: true

require "formula"

module Homebrew
  module_function

  def list_deps_args
    Homebrew::CLI::Parser.new do
      description <<~EOS
        List all of the dependencies for each formula in homebrew/core
      EOS

      named_args :none
    end
  end

  def list_deps
    args = list_deps_args.parse

    puts "{"

    Formula.all.sort_by(&:name).each do |formula|
      next unless formula.tap.core_tap?

      puts "  #{formula.name.inspect}: #{formula.recursive_dependencies.map(&:name).sort.inspect},"
    end

    puts "}"
  end
end
