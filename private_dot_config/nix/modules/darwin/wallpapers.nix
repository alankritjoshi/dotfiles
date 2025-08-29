{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Ensure fd is available for wallpaper scripts
    fd
    
    # Fetch wallpapers from selected collections
    (writeShellScriptBin "fetch-wallpapers" ''
      WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
      mkdir -p "$WALLPAPER_DIR"
      
      echo "Fetching wallpapers from selected collections..."
      
      # JaKooLit Wallpaper Bank
      if [ ! -d "$WALLPAPER_DIR/jakoolit" ]; then
        echo "Cloning JaKooLit wallpapers..."
        git clone --depth 1 https://github.com/JaKooLit/Wallpaper-Bank "$WALLPAPER_DIR/jakoolit"
      else
        echo "Updating JaKooLit wallpapers..."
        cd "$WALLPAPER_DIR/jakoolit" && git pull
      fi
      
      # Mohammed Mehdi wallpapers
      if [ ! -d "$WALLPAPER_DIR/mohammedmehdio" ]; then
        echo "Cloning Mohammed Mehdi wallpapers..."
        git clone --depth 1 https://github.com/mohammedmehdio/Wallpaper-Collection "$WALLPAPER_DIR/mohammedmehdio"
      else
        echo "Updating Mohammed Mehdi wallpapers..."
        cd "$WALLPAPER_DIR/mohammedmehdio" && git pull
      fi
      
      # MyLinuxForWork wallpapers
      if [ ! -d "$WALLPAPER_DIR/mylinuxforwork" ]; then
        echo "Cloning MyLinuxForWork wallpapers..."
        git clone --depth 1 https://github.com/mylinuxforwork/wallpaper "$WALLPAPER_DIR/mylinuxforwork"
      else
        echo "Updating MyLinuxForWork wallpapers..."
        cd "$WALLPAPER_DIR/mylinuxforwork" && git pull
      fi
      
      # dharmx walls
      if [ ! -d "$WALLPAPER_DIR/dharmx" ]; then
        echo "Cloning dharmx walls..."
        git clone --depth 1 https://github.com/dharmx/walls "$WALLPAPER_DIR/dharmx"
      else
        echo "Updating dharmx walls..."
        cd "$WALLPAPER_DIR/dharmx" && git pull
      fi
      
      # Gruvbox wallpapers
      if [ ! -d "$WALLPAPER_DIR/gruvbox" ]; then
        echo "Cloning Gruvbox wallpapers..."
        git clone --depth 1 https://github.com/AngelJumbo/gruvbox-wallpapers "$WALLPAPER_DIR/gruvbox"
      else
        echo "Updating Gruvbox wallpapers..."
        cd "$WALLPAPER_DIR/gruvbox" && git pull
      fi
      
      echo "Wallpapers downloaded to $WALLPAPER_DIR"
      echo "Total wallpapers available:"
      ${fd}/bin/fd -e jpg -e jpeg -e png -e webp . "$WALLPAPER_DIR" | wc -l
    '')
    
    # Random wallpaper setter
    (writeShellScriptBin "random-wallpaper" ''
      WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
      
      # Check if wallpaper directory exists
      if [ ! -d "$WALLPAPER_DIR" ]; then
        echo "Wallpaper directory not found. Run 'fetch-wallpapers' first."
        exit 1
      fi
      
      # Find all image files using fd - handle spaces properly
      IFS=$'\n'
      WALLPAPERS=($(${fd}/bin/fd -e jpg -e jpeg -e png -e webp . "$WALLPAPER_DIR" 2>/dev/null))
      unset IFS
      
      # Check if any wallpapers found
      if [ ''${#WALLPAPERS[@]} -eq 0 ]; then
        echo "No wallpapers found. Run 'fetch-wallpapers' first."
        exit 1
      fi
      
      # Select random wallpaper
      RANDOM_WALLPAPER="''${WALLPAPERS[$RANDOM % ''${#WALLPAPERS[@]}]}"
      
      # Set wallpaper using osascript
      osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$RANDOM_WALLPAPER\""
      
      # Save current wallpaper path
      echo "$RANDOM_WALLPAPER" > "$HOME/.current-wallpaper"
      
      # Display notification
      osascript -e "display notification \"$(basename "$RANDOM_WALLPAPER")\" with title \"Wallpaper Changed\""
      
      echo "Wallpaper set to: $RANDOM_WALLPAPER"
    '')
    
    # Get current wallpaper
    (writeShellScriptBin "current-wallpaper" ''
      if [ -f "$HOME/.current-wallpaper" ]; then
        echo "Current wallpaper: $(cat "$HOME/.current-wallpaper")"
      else
        echo "No wallpaper history found"
      fi
    '')
  ];
}