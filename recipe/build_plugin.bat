@echo off
setlocal

@for /f "tokens=3" %%V in ('findstr /R /C:"^channel *= *" rust-toolchain.toml') do @set "UPSTREAM_RUST_VERSION=%%~V"
@for /f "tokens=2" %%V in ('rustc --version') do @set "COMPILER_RUST_VERSION=%%V"
if not defined UPSTREAM_RUST_VERSION (
    echo Could not read the Rust channel from rust-toolchain.toml 1>&2
    exit /b 1
)

if not "%UPSTREAM_RUST_VERSION%"=="%COMPILER_RUST_VERSION%" (
    echo Rust version mismatch: the conda-build variant selected rustc %COMPILER_RUST_VERSION%, but rust-toolchain.toml specifies %UPSTREAM_RUST_VERSION% 1>&2
    exit /b 1
)

cargo build --locked --profile release
if %errorlevel% NEQ 0 exit /b %errorlevel%

if not exist %LIBRARY_PREFIX%\bin mkdir %LIBRARY_PREFIX%\bin
copy .\target\%CARGO_BUILD_TARGET%\release\zenoh_plugin_webserver.dll %LIBRARY_PREFIX%\bin\
if %errorlevel% NEQ 0 exit /b %errorlevel%

cargo-bundle-licenses --format yaml --output %SRC_DIR%\THIRDPARTY.yml
if %errorlevel% NEQ 0 exit /b %errorlevel%
