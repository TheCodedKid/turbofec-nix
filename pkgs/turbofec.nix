{
  lib,
  stdenv,
  autoreconfHook,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "turbofec";
  version = "0.1";

  src = lib.cleanSource ../.;
  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  # NOTE ON SIMD / PORTABILITY:
  # The AX_EXT autoconf macro probes the *build host's* CPU (via cpuid) and
  # #defines HAVE_SSE3 / HAVE_SSE4_1 / HAVE_AVX2, which select the SIMD code
  # paths in src/conv_sse.h. src/Makefile.am then compiles with `-march=native`,
  # which is the only thing that actually enables those intrinsics in gcc.
  # The HAVE_* macros and the compiler's enabled ISA are therefore only
  # consistent when the arch flag matches host detection (i.e. -march=native).
  # Consequences:
  #   * The build is tuned to, and reproducible only on, the host CPU class.
  #   * The resulting binary may SIGILL on a CPU older than the build machine.
  # This matches upstream's documented build and is the only combination that
  # compiles cleanly without rewriting the SIMD selection logic.
  #
  # nixpkgs' cc-wrapper strips `-march=native` by default (NIX_ENFORCE_NO_NATIVE)
  # for reproducibility. That would leave gcc at the baseline ISA while AX_EXT's
  # host-detected HAVE_AVX2/HAVE_SSE4_1 macros still select those intrinsics ->
  # "target specific option mismatch". We opt out so the arch flag is honored.

  env = {
    NIX_ENFORCE_NO_NATIVE = false;
    NIX_CFLAGS_COMPILE = "-fcommon";
  };

  doCheck = true;

  meta = {
    description = "LTE forward error correction encoders and decoders (convolutional + turbo codes)";
    homepage = "https://github.com/ttsou/turbofec";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
  };
})
