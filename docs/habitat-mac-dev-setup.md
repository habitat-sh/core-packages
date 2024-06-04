# Habitat MacOS Dev Setup

# Setting Up a VM

You can run the MacOS plan builds inside a VM using UTM to increase reproducibilty.

1. Install [UTM](https://mac.getutm.app/)
2. Download IPSW install image (https://ipsw.me)
3. Install and Setup a MacOS VM from the IPSW image on UTM (https://docs.getutm.app/guest-support/macos/)

# Inside the VM / Host

These instructions must be executed after the [Habitat Store](./habitat-store-setup.md) is setup

```bash
# Install homebrew, source: https://brew.sh/
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install build dependencies
# protobuf - required for habitat compilation
# wget, coreutils, gnu-tar, xz - required for hab-plan-build script in native package builds
# xcode - required for all macos plans that make use of the C compiler in anyway
brew install protobuf wget coreutils gnu-tar xz xcodes

# Install xcode version for your macos
# Please check this url to see the versions compatible with your OS version.
# It is recommended to install the latest non-beta version that is compatible with your OS version.
# You will be prompted for your apple id and password to complete this installation 
xcodes install <your-os-compatible-version>

# checkout habitat git repository
git clone https://github.com/habitat-sh/habitat.git
# switch to the habitat repo
pushd habitat
# checkout the macos branch
git checkout jj/aarch64-darwin-bootstrap
# build and install hab locally in debug mode to avoid build failure due to absence of SSL certificates
cargo install --path components/hab --bin hab --debug --locked
# exit the habitat repo
popd

# checkout hab-auto-build repository
git clone https://github.com/habitat-sh/hab-auto-build.git
# switch to the hab-auto-build repo
pushd hab-auto-build
# build and install hab-auto-build locally 
cargo install --path .
# exit the hab-auto-build repo
popd

# checkout core-packages repository
git clone https://github.com/habitat-sh/core-packages.git
# switch to the core packages repo
pushd core-packages
# checkout the macos branch
git checkout jj/macos-plans
# run hab-auto-build with sudo
sudo -E $(which hab-auto-build) build
```