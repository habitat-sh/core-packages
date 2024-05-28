### Fixing Dynamic Library References on macOS for Habitat Packages

When packaging dynamic libraries with Habitat on macOS, it's crucial to ensure that the `LC_ID` (Load Command Identifier) matches the installed path of the library. This helps the system locate and load the library correctly at runtime. Here's how to fix dynamic library references using the `install_name_tool`:

#### Changing the LC_ID of a Binary

The `LC_ID` must be set to the installed path of the library. This can be done using the `install_name_tool`.

**Usage:**
```bash
install_name_tool -id <ID> <LIBRARY_PATH>
```

**Example:**
```bash
install_name_tool -id /hab/pkgs/core/zlib/version/release/lib/libz.dylib /hab/pkgs/zlib/version/release/lib/libz.dylib
```

**Explanation:**
- `install_name_tool -id /hab/pkgs/core/zlib/version/release/lib/libz.dylib /hab/pkgs/zlib/version/release/lib/libz.dylib`: This command sets the `LC_ID` of the library located at `/hab/pkgs/zlib/version/release/lib/libz.dylib` to match its installed path. This ensures that the library is correctly identified and linked at runtime.

#### Changing Library References

You can also use `install_name_tool` to change the references to dynamic libraries within a binary. This is necessary when the paths to the libraries have changed or when you want to ensure that binaries reference the correct versions of the libraries.

**Usage:**
```bash
install_name_tool -change <OLD_REFERENCE> <NEW_REFERENCE> <LIBRARY_PATH>
```

**Example:**
```bash
install_name_tool -change /usr/local/lib/libz.dylib /hab/pkgs/core/zlib/version/release/lib/libz.dylib /hab/pkgs/your_package/version/release/bin/your_binary
```

**Explanation:**
- `install_name_tool -change /usr/local/lib/libz.dylib /hab/pkgs/core/zlib/version/release/lib/libz.dylib /hab/pkgs/your_package/version/release/bin/your_binary`: This command changes the reference from the old library path (`/usr/local/lib/libz.dylib`) to the new library path (`/hab/pkgs/core/zlib/version/release/lib/libz.dylib`) in the binary located at `/hab/pkgs/your_package/version/release/bin/your_binary`. This ensures that the binary uses the correct version of the library from the specified path.
