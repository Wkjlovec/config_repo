set -g fish_greeting

if status is-interactive
    fish_vi_key_bindings
end

if test -d /opt/homebrew/bin
    fish_add_path /opt/homebrew/bin
end

if test -d /usr/local/bin
    fish_add_path /usr/local/bin
end

set -gx EDITOR nvim
set -gx VISUAL nvim

alias ll='ls -la'
alias vim='nvim'
alias vi='nvim'
