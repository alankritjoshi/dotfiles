{ config, pkgs, lib, ... }:

lib.mkIf config.alankrit.isWork {
  # Work-specific Homebrew configuration (Shopify)
  homebrew = {
    # Additional taps for work
    taps = [
      # "databricks/databricks"  # Uncomment if needed
    ];
    
    # Additional brews for work
    brews = [
      # "databricks"  # Uncomment if needed
    ];
    
    # Work-specific GUI applications
    casks = [
      # Communication & Productivity
      "slack"
      "fellow"
      "tuple"
      
      # Security & Monitoring
      "cloudflare-warp"
      "santa"
      "trailer"
    ];
  };
}