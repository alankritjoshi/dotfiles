final: prev: {
  # Skip fish's upstream test suite, which currently fails on aarch64-darwin.
  fish = prev.fish.overrideAttrs (old: {
    doCheck = false;
  });
}
