if status is-interactive
    # Commands to run in interactive sessions can go here
end
starship init fish | source

export fish_greeting

alias ls='eza --icons=always'
alias l='eza --icons -l'
alias la='eza --icons -a'
alias lla='eza --icons -la'
alias lt='eza --icons -T'
alias lta='eza --icons -a -T'

alias cat='bat'
alias man='batman'

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end

zoxide init fish | source

export FZF_DEFAULT_OPTS='
  --color fg:#5d6466,bg:#0A1114
  --color bg+:#67B0E8,fg+:#2c2f30
  --color hl:#dadada,hl+:#26292a,gutter:#141B1E
  --color pointer:#373d49,info:#606672
  --border
  --color border:#1e2527
  --height 20'

# Created by `pipx` on 2025-01-03 06:32:25
set PATH $PATH /home/aditya/.local/bin

set -Ux LIBVA_DRIVER_NAME mesa

alias vim=nvim
alias nano=nvim

function icat
    fd -t f -e png -e jpg -e jpeg |
        fzf \
            --preview-window='right:60%' \
            --preview '
                set w (math -s0 "$FZF_PREVIEW_COLUMNS - 6")
                set h (math -s0 "$FZF_PREVIEW_LINES - 4")

                kitty +kitten icat \
                    --clear \
                    --transfer-mode=file \
                    --stdin=no \
                    --scale-up \
                    --place "$w"x"$h"@3x2 \
                    {}
            '
end

fish_add_path /home/aditya/.spicetify
alias fetch=fastfetch
