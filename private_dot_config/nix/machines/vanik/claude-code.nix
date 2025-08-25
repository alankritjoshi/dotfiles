{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    (writeScriptBin "claude-statusline" ''
      #!${pkgs.ruby}/bin/ruby
      ${builtins.readFile ./scripts/claude-statusline.rb}
    '')
  ];

  programs.claude-code = {
    enable = true;
    settings = {
      apiKeyHelper = "/opt/dev/bin/devx llm-gateway print-token --key";
      env = {
        ANTHROPIC_BASE_URL = "https://proxy.shopify.ai/vendors/anthropic-claude-code";
        ANTHROPIC_MODEL = "claude-opus-4-1";
        MAX_THINKING_TOKENS = "32000";
      };
      model = "opus";
      notificationHooks = {
        "user-prompt-submit" = "/Users/alankritjoshi/.config/scripts/notify.sh USER \"%prompt%\"";
        "assistant-response-complete" = "/Users/alankritjoshi/.config/scripts/notify.sh ASSISTANT \"%message%\"";
      };
      statusline = {
        enabled = true;
        command = "claude-statusline";
      };
      mcpServers = {
        shopify-docs = {
          command = "/opt/dev/bin/devx";
          args = ["llm-gateway" "print-token"];
          env = {
            SHOPIFY_DOCS_MCP_SERVER_TOKEN = {
              command = "/opt/dev/bin/devx";
              args = ["llm-gateway" "print-token"];
            };
          };
        };
        buildkite-mcp = {
          command = "npx";
          args = ["-y" "@ajosh0504/buildkite-mcp" "shopify"];
          env = {
            BUILDKITE_TOKEN = {
              command = "/opt/dev/bin/devx";
              args = ["buildkite" "token"];
            };
          };
        };
        shopify-cookbook-mcp = {
          command = "npx";
          args = ["-y" "@ajosh0504/shopify-cookbook-mcp" "--prod"];
        };
        linear-mcp = {
          command = "npx";
          args = ["-y" "@ajosh0504/linear-mcp"];
          env = {
            LINEAR_API_KEY = {
              command = "/opt/dev/bin/devx";
              args = ["llm-gateway" "print-token" "--key=linear-api-key"];
            };
          };
        };
      };
    };
  };
}