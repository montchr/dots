{ config, pkgs, lib, home-manager, options, ... }:

with lib;

let
  mkOptStr = value:
    mkOption {
      type = with types; uniq str;
      default = value;
    };

  mkSecret = description: default:
    mkOption {
      inherit description default;
      type = with types; either str (listOf str);
    };

  mkOpt = type: default: mkOption { inherit type default; };
  mkOpt' = type: default: description:
    mkOption { inherit type default description; };

  mkBoolOpt = default:
    mkOption {
      inherit default;
      type = types.bool;
      example = true;
    };

in {
  options = with types; {
    dotfield = let t = either str path;
    in rec {
      # TODO: or is there a way to just use the flake dir?
      configDir = mkOpt t (toString ../../.);
      dir = mkOpt t (findFirst pathExists (toString ../.) [
        "${config.my.user.home}/.config/dotfield"
        "/etc/dotfiles"
      ]);
      binDir = mkOpt t "${config.dotfield.dir}/bin";
      modulesDir = mkOpt t "${config.dotfield.dir}/modules";
    };

    my = {
      name = mkOptStr "Chris Montgomery";
      timezone = mkOptStr "America/New_York";
      username = mkOptStr "montchr";
      website = mkOptStr "https://github.com/montchr";
      github_username = mkOptStr "montchr";
      email = mkOptStr "chris@cdom.io";
      key = mkOptStr "0x135EEDD0F71934F3";
      terminal = mkOptStr "kitty";
      nix_managed = mkOptStr
        "DO NOT EDIT! - managed by Nix - see source inside ${config.dotfield.dir}";
      user = mkOption { type = options.users.users.type.functor.wrapped; };

      hm = {
        file = mkOpt' attrs { } "Files to place directly in $HOME";
        configFile = mkOpt' attrs { } "Files to place in $XDG_CONFIG_HOME";
        dataFile = mkOpt' attrs { } "Files to place in $XDG_DATA_HOME";
      };

      xdg = let t = either str path;
      in {
        bin = mkOpt t "$HOME/.local/bin";
        cache = mkOpt t "$HOME/.cache";
        config = mkOpt t "$HOME/.config";
        data = mkOpt t "$HOME/.local/share";
        lib = mkOpt t "$HOME/.local/lib";
      };

      xdgPaths = let home = config.my.user.home;
      in {
        bin = mkOpt str "${home}/.local/bin";
        cache = mkOpt str "${home}/.cache";
        config = mkOpt str "${home}/.config";
        data = mkOpt str "${home}/.local/share";
        lib = mkOpt str "${home}/.local/lib";
      };

      env = mkOption {
        type = attrsOf (oneOf [ str path (listOf (either str path)) ]);
        apply = mapAttrs (n: v:
          if isList v then
            concatMapStringsSep ":" (x: toString x) v
          else
            (toString v));
        default = { };
        description = "Environment variables.";
      };
    };
  };

  config = {
    users.users.${config.my.username} = mkAliasDefinitions options.my.user;

    my = {
      user = {
        home = if pkgs.stdenv.isDarwin then
          "/Users/${config.my.username}"
        else
          "/home/${config.my.username}";

        description = "Primary user account";
      };

      env = {
        DOTFIELD = "$XDG_CONFIG_HOME";
        DOTFIELD_DIR = "$XDG_CONFIG_HOME";
        DOTFIELD_BIN = "$XDG_BIN_HOME";
        GITHUB_USER = config.my.github_username;
        # HISTFILE = "$XDG_DATA_HOME/bash/history";
        # INPUTRC = "$XDG_CONFIG_HOME/readline/inputrc";
        LESSHISTFILE = "$XDG_CACHE_HOME/lesshst";
        WGETRC = "$XDG_CONFIG_HOME/wgetrc";
      };

      # TODO: conflicts with yabai. find a way to merge multiple source dir contents into a single target.
      # hm = {
      #   file = {
      #     ".local/bin" = {
      #       recursive = true;
      #       source = ../bin;
      #     };
      #   };
      # };
    };

    # TODO: these vars should more than likely live in `my.env` instead! for
    # example, `$DOTFIELD` is empty, and `$WGETRC` is set to live at `/wgetrc`.
    # but be careful, because we don't want to break the xdg vars. probably best
    # to unset them here?
    environment = {
      variables = with config.my; {
        XDG_BIN_HOME = "${xdg.bin}";
        XDG_CACHE_HOME = "${xdg.cache}";
        XDG_CONFIG_HOME = "${xdg.config}";
        XDG_DATA_HOME = "${xdg.data}";
        XDG_LIB_HOME = "${xdg.lib}";

        # Conform more programs to XDG conventions. The rest are handled by their
        # respective modules.
        #
        # TODO: move a lot of the stuff in ~/.config/shell/profile into here or
        # specific modules.
        #
        # TODO: setup aspell ASPELL_CONF = '' per-conf
        # $XDG_CONFIG_HOME/aspell/aspell.conf; personal
        # $XDG_CONFIG_HOME/aspell/en_US.pws; repl
        # $XDG_CONFIG_HOME/aspell/en.prepl;
        # '';

      };
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      users.${config.my.username} = {
        home = {
          # Necessary for home-manager to work with flakes, otherwise it will
          # look for a nixpkgs channel.
          stateVersion = if pkgs.stdenv.isDarwin then
            "21.11"
          else
            config.system.stateVersion;
          username = config.my.username;
          file = mkAliasDefinitions options.my.hm.file;
        };

        xdg = {
          enable = true;
          configFile = mkAliasDefinitions options.my.hm.configFile;
          dataFile = mkAliasDefinitions options.my.hm.dataFile;
        };

        programs = {
          # Let Home Manager install and manage itself.
          home-manager.enable = true;
        };
      };
    };

    environment.extraInit = concatStringsSep "\n"
      (mapAttrsToList (n: v: ''export ${n}="${v}"'') config.my.env);
  };
}
