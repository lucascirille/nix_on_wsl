{ pkgs, inputs, ... }:

{
  home.username = "dotneit";
  home.homeDirectory = "/home/dotneit";

  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    git
    curl
    wget
    neovim
    ripgrep
    fd
    fzf
    sesh
    delta
    zoxide
    htop

    (inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      doCheck = false;
    }))
  ];

  programs.home-manager.enable = true;

  # --------------------------------------------------
  # ZSH
  # --------------------------------------------------

  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;

      plugins = [
        "git"
        "sudo"
      ];

      theme = "robbyrussell";
    };

shellAliases = {
  btw = "echo i use nix, btw";
  nv = "nvim";
  hms = "home-manager switch --flake ~/.dotfiles#dotneit";
};
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  # --------------------------------------------------
  # TMUX
  # --------------------------------------------------

  programs.tmux = {
    enable = true;

    mouse = true;
    baseIndex = 1;
    keyMode = "vi";
    terminal = "tmux-256color";
    prefix = "C-a";
    escapeTime = 0;
    historyLimit = 1000000;

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      resurrect
      continuum
      tmux-thumbs
      tmux-fzf
      fzf-tmux-url

      # Floax
      (mkTmuxPlugin {
        pluginName = "floax";
        version = "unstable-2024";

        src = pkgs.fetchFromGitHub {
          owner = "omerxx";
          repo = "tmux-floax";
          rev = "main";
          hash = "sha256-9Hb9dn2qHF6KcIhtogvycX3Z0MoQrLPLCzZXtjGlPHw=";
        };
      })
    ];

    extraConfig = ''
      # --------------------------------------------------
      # TERMINAL
      # --------------------------------------------------

      set-option -sa terminal-features ',xterm-256color:RGB'
      set-option -g terminal-overrides ',xterm-256color:RGB'

      # --------------------------------------------------
      # CORE BEHAVIOR
      # --------------------------------------------------

      set -g detach-on-destroy off
      set -g renumber-windows on
      set -g set-clipboard on
      set -g status-position bottom

      # --------------------------------------------------
      # CATPPUCCIN MOCHA THEME
      # --------------------------------------------------

      set-option -g status-bg default
      set-option -g status-left-length 100
      set-option -g status-right-length 100

      # Left: Session name
      set-option -g status-left "#[fg=#a6e3a1,bg=default]#[fg=#1e1e2e,bg=#a6e3a1,bold] 󰄛 #S #[fg=#a6e3a1,bg=default] "

      # Inactive windows
      set-window-option -g window-status-format "#[fg=#45475a,bg=default] #[fg=#cdd6f4,bg=#45475a] #W #I #[fg=#45475a,bg=default]"

      # Active window
      set-window-option -g window-status-current-format "#[fg=#89b4fa,bg=default] #[fg=#1e1e2e,bg=#89b4fa,bold] #W #I #[fg=#89b4fa,bg=default]"

      # Window separator
      set-window-option -g window-status-separator ""

      # Right: Directory and time
      set-option -g status-right "#[fg=#cba6f7,bg=default]#[fg=#1e1e2e,bg=#cba6f7,bold]  #{b:pane_current_path} #[fg=#cba6f7,bg=default] #[fg=#94e2d5,bg=default]#[fg=#1e1e2e,bg=#94e2d5,bold] 󰃰 %H:%M #[fg=#94e2d5,bg=default] "

      # Pane borders
      set -g pane-active-border-style "fg=#89b4fa,bg=default"
      set -g pane-border-style "fg=#45475a,bg=default"

      # --------------------------------------------------
      # FLOAX
      # --------------------------------------------------

      set -g @floax-width '80%'
      set -g @floax-height '80%'
      set -g @floax-border-color '#89b4fa'
      set -g @floax-text-color '#cdd6f4'
      set -g @floax-bind 'p'
      set -g @floax-change-path 'true'

      # --------------------------------------------------
      # SESH
      # --------------------------------------------------

      bind-key "o" run-shell "sesh connect \"$(
        sesh list --icons | fzf-tmux -p 75%,85% \
          --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
          --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find ^e dotfiles' \
          --bind 'tab:down,btab:up' \
          --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
          --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
          --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
          --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
          --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
          --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
          --bind 'ctrl-e:execute(sesh connect ~/.dotfiles)+abort'
      )\""

      # --------------------------------------------------
      # PLUGIN INTEGRATIONS
      # --------------------------------------------------

      set -g @continuum-restore 'on'
      set -g @resurrect-strategy-nvim 'session'

      # FZF URL
      set -g @fzf-url-fzf-options '-p 60%,30% --prompt="   " --border-label=" Open URL "'
      set -g @fzf-url-history-limit '2000'

      # --------------------------------------------------
      # CUSTOM KEYBINDINGS
      # --------------------------------------------------

      # Vim-style pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Swap windows
      bind -r H swap-window -t -1 \; select-window -t -1
      bind -r L swap-window -t +1 \; select-window -t +1

      # Swap panes
      bind -r J swap-pane -D
      bind -r K swap-pane -U

      # New windows and splits in current directory
      bind c new-window -c "#{pane_current_path}"
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # Vim-style pane resizing
      bind -r -T prefix , resize-pane -L 20
      bind -r -T prefix . resize-pane -R 20
      bind -r -T prefix - resize-pane -D 7
      bind -r -T prefix = resize-pane -U 7

      # Connect to dotfiles
      bind . run-shell "sesh connect ~/.dotfiles"
    '';
  };

    programs.antigravity-cli = {
    enable = true;
    # Tell the module to use the flake's package instead of looking in standard nixpkgs
    package = inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli;

    # context = {
    #   GEMINI = ./ai/context/GEMINI.md;
    # };
    #
    # skills = ./ai/skills;
  };

programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Lucas Cirille";
        email = "lucas.cirille@gmail.com";
        signingkey = "~/.ssh/id_ed25519.pub";
      };
      gpg = {
        format = "ssh";
      };
      commit = {
        gpgsign = true;
      };
      init = {
        defaultBranch = "main";
      };
      merge = {
        conflictStyle = "zdiff3"; # Muestra OURS, BASE (ancestro) y THEIRS
        tool = "nvimdiff";
      };
      mergetool = {
        keepBackup = false; # Evita que Git deje archivos .orig basura
        prompt = false;
      };
      rerere = {
        enabled = true; # Recuerda cómo resolviste conflictos previos
        autoupdate = true; # Stagea automáticamente si rerere lo resolvió
      };
      diff = {
        algorithm = "histogram"; # Diffs más limpios al mover bloques de código
      };
    };
  };
  programs.lazygit = {
    enable = true;
    settings = {
      os = {
        # Cuando presionás 'e' en LazyGit, abre el archivo en Neovim en la línea exacta
        edit = "nvim {{filename}}";
        editAtLine = "nvim +{{line}} {{filename}}";
      };
      gui = {
        theme = {
          activeBorderColor = [
            "#89b4fa"
            "bold"
          ];
          inactiveBorderColor = [ "#6c7086" ];
        };
      };
      git = {
        # Nueva sintaxis de LazyGit
        diffRenderers = [
          {
            colorArg = "always";
            command = "delta --dark --paging=never";
          }
        ];
        merging = {
          args = "--no-ff";
        };
      };
    };
  };

  xdg.configFile."workmux/config.yaml".text = ''
  nerdfont: true
  worktree_dir: ~/.workmux/{project}
  merge_strategy: rebase
  base_branch: auto
  mode: session
  default_session: main

  agent: agy

  windows:
    - name: agente
      panes:
        - command: <agent>
          focus: true
    - name: terminal
      panes:
        - command: zsh
'';
}
