# unixodbc

ODBC driver manager for Unix. ODBC is an open specification for providing application developers with a predictable API
 with which to access Data Sources.

## Maintainers

* The Habitat Maintainers: <humans@habitat.sh>

## Type of Package

Binary package

## Usage

ODBCSYSINI and ODBCINI environment variables can be used to specify the location of your ODBC configuraiton. DO NOT
 use this package without setting the config location, as it will default to the $pkg_prefix/etc config that unixODBC
 specifies at build time.

### Example Usage with SQL Server 2017 ODBC Driver

Include unixODBC and msodbcsql17 as runtime dependencies in your application:

```bash
pkg_deps=(
  core/msodbcsql17
  core/unixodbc
)
```

Include odbcinst.ini in your application config:

```
[ODBC Driver 17 for SQL Server]
Description=Microsoft ODBC Driver 17 for SQL Server
Driver={{pkgPathFor "core/msodbcsql17"}}/lib/libmsodbcsql-17.2.so.0.1
UsageCount=1
```

In your run hook, set ODBCSYSINI environment variable to point at your app config path.

```
export ODBCSYSINI="{{pkg.svc_config_path}}"
```

You can then consume the ODBC driver via application unixODBC bindings.

NOTE: You could also include odbc.ini in your config if you aren't setting up your connection details from inside your
 app.
