set -euxo pipefail

upstream_rust_version=$(sed -n 's/^channel[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' rust-toolchain.toml)
compiler_rust_version=$(rustc --version | awk '{ print $2 }')

if [[ -z "${upstream_rust_version}" ]]; then
    echo "Could not read the Rust channel from rust-toolchain.toml" >&2
    exit 1
fi

if [[ "${upstream_rust_version}" != "${compiler_rust_version}" ]]; then
    echo "Rust version mismatch: the conda-build variant selected rustc ${compiler_rust_version}, but rust-toolchain.toml specifies ${upstream_rust_version}" >&2
    exit 1
fi

cargo build --locked --profile release
mkdir -p ${PREFIX}/lib
cp ./target/${CARGO_BUILD_TARGET}/release/libzenoh_plugin_webserver${SHLIB_EXT} ${PREFIX}/lib/

cargo-bundle-licenses --format yaml --output ${SRC_DIR}/THIRDPARTY.yml
