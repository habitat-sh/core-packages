# GCC Bootstrapping

Packaging GCC is essential to building other packages in a Linux system. Understanding how a C compiler and GCC work is the biggest challenge. 

Many core system packages such as binutils, glibc, and Linux kernel are built with GCC. Additionally, popular programming languages like Python and Ruby also use GCC in their build process. By packaging GCC correctly, we ensure that these packages can be built and run smoothly on our system

Here, we've gathered all the information you need to make this task easy.

## How Habitat Packaging creates portable applications

Each Habitat package is given a unique store path, such as `/hab/pkgs/core/openssl/1.1.1g/20200612063614`. This path includes the name and version of the package, as well as a timestamp indicating when it was built.

By relying on these unique store paths, Habitat ensures that dependencies are always the same across different systems. When an application is packaged, all of its dependencies are included in the resulting Habitat package along with their own unique store paths. This means that even if two applications require different versions of the same dependency, they can both be installed and run without conflict.

Furthermore, because each Habitat package is self-contained and isolated from other packages on the system, there is no risk of one application inadvertently interfering with another due to shared dependencies.

This approach not only simplifies deployment and management of applications but also provides a high degree of reproducibility. By using these unique store paths to ensure that all dependencies are consistent across different systems, developers can be confident that their applications will behave consistently regardless of where they are deployed.

## Creating a Portable Compiler / Linker

he final goal of this process is to create a gportable cc compiler and linker that can work correctly in a ny environment TFor this the compiler and linker needs to be able to do the following.

The compiler must be able to:

-   Find *glibc headers\[1]* if compiling a C / C++ binary
-   Find *libstdc++ headers\[2]* if compiling a C++ binary
-   Find the *C runtime start files \[3]* to link when creating binaries
-   Find the exact linker to use even if there are multiple linkers in the path
-   Correctly decide to set a runtime linker if required

The linker must be able to:

-   Add RUNPATH entries to a binary/shared library for all required shared libraries
-   Add a custom dynamic linker if the compiling a binary

All these requirements can be met by wrapping the compiler and linker with shell scripts that parse and modify the arguments passed to them. This critical step ensures that the compiler works in any environment.

The plan files for binutils packages, such as 'native-cross-binutils', 'build-tools-binutils', 'binutils-stage0', 'binutils-stage1', and 'binutils-base', include the linker wrapper script 'ld-wrapper.sh'.

Similarly, the plan files for gcc packages, such as 'native-cross-gcc-base', 'build-tools-gcc', 'gcc-stage1', and 'gcc', contain the compiler wrapper script 'cc-wrapper.sh'.

## Bootstrapping GCC

Bootstrapping GCC is the process of building a new fully featured GCC compiler. Ideally this is done from scratch, starting with something like a hex editor and building up from there.

However that approach is far to extreme and we settle for something more manageable.  We adopt the approach taken by the [Linux from Scratch](https://www.linuxfromscratch.org/) project which is to do a form of pseudo cross compiling of gcc from an existing architecture to a new one.

It is pseudo cross compiling in the sense that we will use a \`aarch64-unknown-linux-gnu\` tool-chain to create an \`aarch64-hab-linux-gnu\` tool-chain.  Even though both tool-chains are actually for \`aarch64-linux\`, the GCC build system will consider them to be separate systems and do a cross build. To learn more about GCC cross compilation check out section 4 of the Appendix.

The broad steps involved in this are as follows assuming an ARM based platform, specifically \`aarch64-linux\`.

1.  Build a cross binutils, ie: aarch64-hab-linux-gnu prefixed 'ld', 'as', etc.
2.  Build a cross gcc which uses the cross binutils for linking, ie: aarch64-hab-linux-gnu prefixed 'gcc', 'g++', etc.
3.  Use the cross-binutils and cross-gcc to create a minimal glibc and libstdc++
4.  Combine all these into a single package that can be used to cross compile more tools like bash, grep, hab, hab-studio etc for the new platform. Critically, these tools will depend on the minimal glibc and libstdc++ that we created in step 3 and hence be portable to any environment.

The tools created in step 4 along with the libraries in step 3 are called the \`build-tools\`. These \`build-tools\` are fully portable and can be used to create a packages within a hab studio.

## Compiling Build Tools with Complex Dependencies

Some of the build tools are non trivial to build and require many other dependencies. An example of such a tool is the \`hab\` binary itself. It requires rust to be built which in turn has numerous dependencies. The way we overcome this need to build all dependencies of a tool is by leveraging native plan builds.

In a native plan build you can use any dependency available on the host system during the build process. This way we can build the \`build-tools-hab\` package on any platform which has rust already available. Once we build the binaries we patch the runtime linker interpreter path and RUNPATH to make them depend on our \`build-tools-glibc\` and other libraries. This way the binary becomes portable and capable of running inside a studio.

This is the approach we take to create the \`build-tools-hab\` package.


Appendix
========

## 1. C Stdlib Headers

The C standard library, often referred to as glibc, provides a set of headers that contain functions and macros for performing various operations such as memory allocation, process control, and string manipulation. The stdlib.h header file is one of the most commonly used headers in the C standard library, and it contains a set of functions for performing general-purpose operations on data.

Some of the functions defined in stdlib.h include:

-   Memory allocation functions like malloc() and free()
-   Conversion functions like atoi() and atof()
-   Random number generation functions like rand() and srand()
-   Process control functions like exit() and system()

Other commonly used headers in the C standard library include stdio.h for input/output operations, string.h for string manipulation functions, and math.h for mathematical functions. These headers are included in C programs using the #include directive at the beginning of the program file.

## 2. C++ Stdlib Headers

Libstdc++ is the standard C++ library that is used by GCC, the GNU Compiler Collection. It provides a set of functions and classes that are used to implement many of the features of the C++ language, such as containers, iterators, algorithms, and I/O streams.

The libstdc++ headers are a set of header files that define the classes and functions that are part of the libstdc++ library. These headers are included in C++ programs using the #include directive at the beginning of the program file.

Some of the commonly used headers in the libstdc++ library include:

iostream: This header defines the basic input/output stream classes for C++. It includes classes like istream, ostream, and stringstream that are used for reading and writing data to standard input/output streams or other data sources.

vector: This header defines the vector class in C++, which is a dynamic array that can resize itself as needed. It provides a convenient way to store and manipulate collections of data.

algorithm: This header defines a set of standard algorithms that can be used to perform operations on containers such as vectors or arrays. These include functions like sort(), find(), and accumulate().

string: This header defines the string class in C++, which is used for storing and manipulating text strings.

Overall, the libstdc++ headers provide a rich set of tools for C++ programmers to work with, making it easier to write complex programs efficiently and effectively.

## 3. C runtime start files

C runtime start files, also known as "crt" files, are a set of library files that are linked into C programs when they are compiled. These files contain code that is executed before main() is called, and they perform a variety of tasks such as initializing global variables, setting up the stack, and performing operating system specific initialization.

There are different versions of the C runtime start files for different platforms and compilers, and they typically have names like "crt0.o" or "crt1.o". These files are an essential part of the C runtime environment, and they help ensure that C programs run smoothly on a given platform.

## 4. GCC Cross Compiling

The GNU Compiler Collection (GCC) is a versatile suite of compilers, supporting several languages and target architectures. Cross-compilation is the process of compiling code on one machine (the host) to run on a different machine (the target). This is useful when the target system has limited resources, or when you want to develop software for various platforms from a single development environment.

In the context of GCC, cross-compilation typically involves using tools like configure and make to build a cross-compiler that targets a specific architecture, such as AArch64, x86, or MIPS. These tools are prefixed with a target string that identifies the target system, like aarch64-\<vendor>-linux-gnu- for an AArch64 target running a GNU/Linux OS.

Here's an outline of the cross-compilation process:

1.  Acquire the required toolchain: The first step is to obtain a toolchain that contains the necessary cross-compiler and linker for the target system. This can be done by either downloading pre-built binaries or building the toolchain from source.
2.  Configure the build system: The configure script is a shell script that generates a Makefile tailored to the build environment. It checks for available tools, libraries, and system features, and sets the appropriate flags and paths. When cross-compiling, you should provide the --target flag, specifying the target triplet (e.g., aarch64-\<vendor>-linux-gnu). This tells the configure script to search for tools with the target prefix.

For example:

```bash
./configure --target=aarch64-<vendor>-linux-gnu
```

1.  Build the cross-compiled binary: After running the configure script, a Makefile is generated. Running make will build the cross-compiled binary using the cross-compiler and linker. These tools have the target prefix to ensure that the correct tools are used throughout the build process, avoiding conflicts with native compilers.

For example, the cross-compiler for an AArch64 target may have the name aarch64-\<vendor>-linux-gnu-gcc, while the cross-linker may have the name aarch64-\<vendor>-linux-gnu-ld.

1.  Run the binary on the target system: Finally, after the build process is complete, you can transfer the cross-compiled binary to the target system and execute it. The binary is specifically built for the target architecture and should run as expected on the target machine.

To sum up, the cross-compilation process involves obtaining the appropriate toolchain, configuring the build environment with the target prefix, and using the cross-compiler and linker to produce a binary that can run on the target system. This allows developers to create software for different platforms using a single development environment.