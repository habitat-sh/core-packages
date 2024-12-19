# openssl

OpenSSL is an open source project that provides a robust, commercial-grade, and full-featured toolkit for the Transport Layer Security (TLS) and Secure Sockets Layer (SSL) protocols. It is also a general-purpose cryptography library.  See [documentation](https://www.openssl.org)

## Maintainers

* The Core Planners: <chef-core-planners@chef.io>

## Type of Package

Binary package

### Use as Dependency

Binary packages can be set as runtime or build time dependencies. See [Defining your dependencies](https://www.habitat.sh/docs/developing-packages/developing-packages/#sts=Define%20Your%20Dependencies) for more information.

To add core/openssl as a dependency, you can add one of the following to your plan file.

##### Buildtime Dependency

> pkg_build_deps=(core/openssl)

##### Runtime dependency

> pkg_deps=(core/openssl)

### Use as Tool

#### Installation

To install this plan, you should run the following commands to first install, and then link the binaries this plan creates.

``hab pkg install core/openssl --binlink``

will add the following binary to the PATH:

* /bin/openssl

For example:

```bash
$ hab pkg install core/openssl --binlink
» Installing core/openssl
☁ Determining latest version of core/openssl in the 'stable' channel
→ Using core/openssl/1.0.2t/20200306005450
★ Install of core/openssl/1.0.2t/20200306005450 complete with 0 new packages installed.
» Binlinking openssl from core/openssl/1.0.2t/20200306005450 into /bin
★ Binlinked openssl from core/openssl/1.0.2t/20200306005450 to /bin/openssl
```

#### Using an example binary

You can now use the binary as normal.  For example:

``/bin/openssl --help`` or ``openssl --help``

```bash
$ openssl --help
...
...
Standard commands
asn1parse         ca                ciphers           cms
crl               crl2pkcs7         dgst              dh
dhparam           dsa               dsaparam          ec
ecparam           enc               engine            errstr
gendh             gendsa            genpkey           genrsa
...
...
```

### Using fips module for 3.0.9, list fips provider.

# linux

Install the core/openssl package
$ sudo hab pkg install core/openssl/3.0.9/20241017121505
We need to create fipsmodule.cnf on every machine where we build our own application.
The fipsmodule.cnf generated at the time of building OpenSSL at build environment can’t be reused on the different machine
After installation of openssl package the fipsmodule.cnf should be generated and openssl.cnf should be edited
From the $pkg_prefix folder:
$ sudo ./bin/openssl fipsinstall -module lib64/ossl-modules/fips.so -out ./ssl/fipsmodule.cnf -provider_name fips
$ sudo vi ssl/openssl.cnf
In openssl.cnf do the following changes:
>
51c51
< # .include fipsmodule.cnf
---
>  .include $pkg_prefix/ssl/fipsmodule.cnf
61c61
< # fips = fips_sect
---
>  fips = fips_sect
73,74c73
<
<
---
> [fips_sect] ##add this line after [default_sect]

export modules directory
$ export OPENSSL_MODULES=$pkg_prefix/lib64/ossl-modules/
then run
$ ./bin/openssl list -providers
Providers:
  fips
    name: OpenSSL FIPS Provider
    version: 3.0.9
    status: active

The fips provider is listed

# Windows
Install the core/openssl package
> hab pkg install core/openssl/3.0.9/20241217123356

From the $pkg_prefix folder:
> .\bin\openssl.exe fipsinstall -out .\SSL\fipsmodule.cnf -module .\lib\ossl-modules\fips.dll -provider_name fips

In openssl.cnf make changes same as in linux and include fipsmodule.cnf with forward slash in PATH
  > .include 'C:/$pkg_prefix/SSL/fipsmodule.cnf'

set modules directory
> $env:OPENSSL_MODULES='C:$pkg_prefix\lib\\ossl-modules\'

then run
> .\bin\openssl.exe list -providers
