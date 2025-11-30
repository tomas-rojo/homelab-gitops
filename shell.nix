# Configuration for `nix-shell` to setup a development environment.
# See https://nixos.org

let
  pkgs = (import <nixpkgs>) {
    config = {
      allowUnfree = true;  # Required for Terraform >= 1.6.0
    };
  };
  appDir = builtins.toString ./.;
in
  pkgs.mkShell {
    name = "Tomas Homelab Shell";

    buildInputs = with pkgs; [
      terraform
      kubectl
      kubeseal
      argocd
      git
      curl
      jq
    ];

    shellHook = ''
      USER_POLICY_PATH="$HOME/.config/containers"
      USER_POLICY_FILE="$USER_POLICY_PATH/policy.json"
      GLOBAL_POLICY_FILE="/etc/containers/policy.json"
      if [[ ! -e $USER_POLICY_FILE && ! -e $GLOBAL_POLICY_FILE ]]; then
        echo "Create empty $USER_POLICY_FILE"
        mkdir -p $USER_POLICY_PATH
        echo '{"default": [{"type": "insecureAcceptAnything"}]}' | jq > $USER_POLICY_FILE
      fi

      current_git_branch() {
        git config --global --add safe.directory /workspace
        git branch --show-current 2> /dev/null | sed -e 's/\(.*\)/(\1)/'
      }

      export PS1="[HomeLab - Tomas] \[\e[32m\]\w \[\e[91m\]\$(current_git_branch)\[\e[00m\]$ "

      echo ""
      echo "Tool versions:"
      echo "  • Terraform:  $(terraform version | head -n1)"
      echo "  • kubectl:    $(kubectl version --client | awk 'NR==1{printf "%s - ", $0} NR==2{print $0}')"
      echo "  • kubeseal:   $(kubeseal --version 2>&1 | head -n1)"
      echo "  • argocd:     $(argocd version --client --short 2>/dev/null || echo 'argocd CLI')"
      echo ""

      alias k="kubectl"
      alias tf="terraform"
    '';
  }