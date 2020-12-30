# Homebrew Development

Test formulae and tools for Homebrew development

Run the following command to have access to these formulae and tools:

```
brew tap rylan12/development
```

## Commands

I've written the following commands to make my Homebrew development easier:

- [`check`](#check)
- [`check-formula`](#check-formula)

Once this repository has been tapped, run these commands with:

```
brew <command>
```

### `check`

This command automates running `brew style`, `brew typecheck`, `brew man`, and `brew tests` saving time and effort when working on PRs for Homebrew/brew.

```
Usage: brew check [options]

Run the various checks needed before opening a PR in the Homebrew/brew
repository.

  -t, --tests                      Run brew tests.
  -f, --fix                        Pass the --fix option to brew style.
      --exit-on-failure            Exit if a single check fails instead of
                                   running all checks.
      --only                       Run only the specified command. Options are
                                   style, typecheck, man, or tests.
      --except                     Don't run the specified checks. Options are
                                   style, typecheck, or man.
  -d, --debug                      Display any debugging information.
  -q, --quiet                      Make some output more quiet.
  -v, --verbose                    Make some output more verbose.
  -h, --help                       Show this message.
```

### `check-formula`

This command automates testing formulae for PRs to Homebrew/homebrew-core. The command installs and tests the formula as well as running `brew style` and `brew audit` on the formula.

```
Usage: brew check-formula [options] formula

Run the various checks needed on formula before opening a PR in the
Homebrew/homebrew-core repository.

  -f, --fix                        Pass the --fix option to brew style.
      --skip-style                 Don't run brew style.
      --skip-test                  Don't run brew test.
      --skip-audit                 Don't run brew audit.
      --audit-flags                Flags to pass to brew audit. Options are
                                   strict, online, git, or new.
      --continue-on-failure        Run all checks instead of exiting if a
                                   single check fails.
  -k, --keep-formula               Don't uninstall formula when checks are
                                   finished. This is the default if formula
                                   was not installed before running the
                                   checks.
  -u, --uninstall-dependencies     Uninstall the unused dependencies of
                                   formula when checks are finished.
  -d, --debug                      Display any debugging information.
  -q, --quiet                      Make some output more quiet.
  -v, --verbose                    Make some output more verbose.
  -h, --help                       Show this message.
```

## Formulae

So far I have no formulae in this tap.

### How do I install these formulae?
`brew install rylan12/development/<formula>`

Or `brew tap rylan12/development` and then `brew install <formula>`.

## Documentation
`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
