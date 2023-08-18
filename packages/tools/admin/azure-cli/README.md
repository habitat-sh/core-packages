# Azure CLI

The [Azure command-line interface (CLI)](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest) is Microsoft's cross-platform command-line experience for managing Azure resources. Use it in your browser with Azure Cloud Shell, or install it on macOS, Linux, or Windows and run it from the command line.

## Maintainers

The Habitat Maintainers humans@habitat.sh

## Type of Package

Binary package

## Usage

```bash
hab pkg install core/azure-cli
hab pkg binlink core/azure-cli az   # do not try to binlink all the python deps

az --version
```

## Testing

```
hab studio build azure-cli
source results/last_build.env
hab studio run "./azure-cli/tests/test.sh ${pkg_ident}"
```

## Sample Output

```
 ✓ az exe runs
 ✓ az exe outputs the expected version 2.0.57

2 tests, 0 failures
```
