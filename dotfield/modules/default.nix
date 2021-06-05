{ config, pkgs, ... }:

{
  # Roughly in order of precedence.
  imports = [
    ./settings.nix
    ./zsh.nix
    ./bash.nix
    ./direnv.nix
    ./lorri.nix
    ./gpg.nix
    ./ssh.nix
    ./git.nix
    ./kitty.nix
    ./tealdeer.nix
    ./bat.nix
    ./ripgrep.nix
    ./node.nix
    ./gui.nix
    ./python.nix

    ./editors/emacs
    ./espanso
  ];

  my.modules = {
    bat.enable = true;
    bash.enable = true;
    direnv.enable = true;
    git.enable = true;
    gui.enable = true;
    kitty.enable = true;
    lorri.enable = true;
    node.enable = true;
    python.enable = true;
    ripgrep.enable = true;
    ssh.enable = true;
    tealdeer.enable = true;
    zsh.enable = true;

    editors = {
      emacs = {
        enable = true;
        doom.enable = true;
      };
    };
  };

  my.user.packages = with pkgs; [
    linode-cli
    terraform_0_15
  ];

}
