{ self }: { config, lib, pkgs, ... }:

let
  cfg = config.programs.my-quickshell-bar;
  # Generate a config file that Quickshell can read (e.g., as JSON)
  configJson = pkgs.writeText "bar-settings.json" (builtins.toJSON {
    color = cfg.color;
    position = cfg.position;
  });
in {
  options.programs.my-quickshell-bar = {
    enable = lib.mkEnableOption "Quickshell Bar";
    color = lib.mkOption {
      type = lib.types.str;
      default = "#ffffff";
      description = "Background color of the bar.";
    };
    position = lib.mkOption {
      type = lib.types.enum [ "top" "bottom" ];
      default = "top";
      description = "Screen position.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ self.packages.${pkgs.system}.default ];
    
    # Pass settings to your QML by symlinking the generated config
    home.file.".config/my-bar/settings.json".source = configJson;
  };
}
