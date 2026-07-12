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
    };
  };
}