{ config, pkgs, lib, ... }:

{
  programs.claude-code = {
    enable = true;
    settings = {
      model = "opus";
      notificationHooks = {
        "user-prompt-submit" = "/Users/alankritjoshi/.config/scripts/notify.sh USER \"%prompt%\"";
        "assistant-response-complete" = "/Users/alankritjoshi/.config/scripts/notify.sh ASSISTANT \"%message%\"";
      };
      statusline = {
        enabled = true;
        command = "claude-statusline";
      };
    };
  };

  home.packages = with pkgs; [
    (writeScriptBin "claude-statusline" ''
      #!${pkgs.ruby}/bin/ruby
      ${builtins.readFile ../../machines/vanik/scripts/claude-statusline.rb}
    '')
  ];
}