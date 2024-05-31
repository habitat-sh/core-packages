# Habitat Challenges for MacOS Support

## 1. Dynamic Linker Restrictions

### Issue
MacOS does not allow the usage of a dynamic linker that is not the official system dynamic linker.

### Reason
Apple regularly modifies and breaks the syscall interface to the kernel. This means that all syscalls must go through the official system C library, which may change from release to release.

## 2. Lack of chroot Support

### Issue
MacOS does not support `chroot`.

### Reason
MacOS officially deprecated support for the `chroot` tool to harden its runtime. More details can be found [here](https://threedots.ovh/blog/2021/01/chroot-on-modern-macos-disallowed/).

## 3. Lack of Container Support

### Issue
MacOS does not support containers.

### Reason
There is no kernel support for features like cgroups and namespaces that are required to implement container technologies. This means that native package builds can be extremely unreliable as there is no mechanism to standardize the build environment. All package builds, native and otherwise, will also use the same `/hab/pkgs` directory, which will break plan builds unless appropriately isolated.

### Solution
The only official method of isolation supported on MacOS involves using a VM via the Hypervisor and Virtualization Framework. More details can be found [here](https://developer.apple.com/documentation/virtualization).

### Alternative Mechanism
The other mechanism is the use of the undocumented `sandbox-exec` tool. Here are a few reasons to consider this tool:
- `sandbox-exec` isolation is very lightweight compared to running a virtual machine for each build.
- This tool is used to achieve isolation by all current build systems such as Bazel, Nix, etc.
- It is officially deprecated. However, due to its heavy use internally within MacOS, it is highly likely to become unsupported or stop working in the near future. Many of the modern MacOS security features like entitlements are built on top of the `sandbox-exec` profiles internally.

## 4. Complex Installation Process

### Issue
MacOS does not allow the creation of a directory in the root folder. This means you cannot simply create the `/hab` directory even if you have `sudo` permissions. Additionally, installation of Habitat requires a relatively complex installation process that necessitates careful handling of edge cases and partial failures.

### Solution
The basic commands in case of the happy path are as follows:
```sh
/usr/sbin/diskutil apfs addVolume "disk3" "APFS" "Habitat Store" -nomount
uuid=$(/System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -k $disk_id) # disk id must be the id of the disk created in the previous step
sudo vifs # add line `UUID=<uuid> /hab apfs rw,noauto,nobrowse,suid,owners`
sudo vi /etc/synthetic.conf # add line `hab\n` , the newline is important, otherwise it crashes
diskutil mount -mountPoint /hab $uuid
```

The Nix community has managed to create a reliable installer called the Nix Determinate Installer, which can be used as a reference to develop our own. More details can be found [here](https://github.com/DeterminateSystems/nix-installer).

## 5. Code-Signing Requirements

### Issue
MacOS requires binaries to be code-signed for them to work on 3rd-party machines.

### Details
The default linker (`/usr/bin/ld`) on MacOS already does this when linking a binary. However, any tool that strips or modifies the binaries or libraries may invalidate the signature, making the binary or library unusable.