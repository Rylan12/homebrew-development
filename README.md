# Homebrew Development

> [!WARNING]
> I have moved `brew check` and `brew move-cask-core` to my personal tap, [rylan12/personal](https://github.com/Rylan12/homebrew-personal).
> I don't currently use the remaining formulae/commands so I have archived the repository.
> In the future, if I start to use the remaining items, I will migrate them to [rylan12/personal](https://github.com/Rylan12/homebrew-personal) and fix them there.

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
                                   style, vale, typecheck,
                                   generate-man-completions, or tests.
      --except                     Don't run the specified checks. Options are
                                   style, vale, typecheck, or
                                   generate-man-completions.
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

### `relocation-testing`

This formula is designed to be used to test some of the keg and bottle relocation features.

To prepare this formula for testing, install using:

```
brew install --verbose --build-bottle rylan12/development/relocation-testing
```

Then, create a bottle using (to test RPATH relocation, first run `export HOMEBREW_RELOCATE_RPATHS=1`):

```
brew bottle --verbose --json --only-json-tab rylan12/development/relocation-testing
```

The formula contains two `dylib` files (`libfoo.dylib` and `libbar.dylib`) in its `lib` directory. To verify that RPATH relocation has occurred successfully, extract the bottle archive and ensure the following commands return the expected outputs (run in `lib` directory):

```console
$ otool -L *
libbar.dylib:
        @@HOMEBREW_PREFIX@@/opt/relocation-testing/lib/libbar.dylib (compatibility version 0.0.0, current version 0.0.0)
        @@HOMEBREW_PREFIX@@/opt/llvm/lib/libLLVM.dylib (compatibility version 1.0.0, current version 12.0.0)
        /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1292.100.5)
libfoo.dylib:
        @@HOMEBREW_PREFIX@@/opt/relocation-testing/lib/libfoo.dylib (compatibility version 0.0.0, current version 0.0.0)
        @@HOMEBREW_PREFIX@@/opt/llvm/lib/libLLVM.dylib (compatibility version 1.0.0, current version 12.0.0)
        @loader_path/libbar.dylib (compatibility version 0.0.0, current version 0.0.0)
        /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1292.100.5)

$ otool -l * | rg -A2 LC_RPATH
          cmd LC_RPATH
      cmdsize 48
         path @@HOMEBREW_PREFIX@@/opt/llvm/lib (offset 12)
--
          cmd LC_RPATH
      cmdsize 32
         path @loader_path/ (offset 12)
--
          cmd LC_RPATH
      cmdsize 48
         path @@HOMEBREW_PREFIX@@/opt/llvm/lib (offset 12)
--
          cmd LC_RPATH
      cmdsize 32
         path @loader_path/ (offset 12)
```

### How do I install these formulae?
`brew install rylan12/development/<formula>`

Or `brew tap rylan12/development` and then `brew install <formula>`.

## Documentation
`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
