#
# ~/.bashrc
#

export GTK_THEME=Adwaita:dark
export GTK_RC_FILES=/usr/share/themes/Adwaita-dark/gtk-2.0/gtkrc
export QT_STYLE_OVERRIDE=adwaita-dark
export VISUAL=nvim

export PATH=$PATH:~/.cargo/bin

# If not running interactively, don't do anything
[[ $- != *i* ]] && return


PS1='[\u@\h \W]\$ '


alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias ls='lsd'
alias cd='z'
alias grep='rg'
alias find='fd'
alias cat='bat'
alias rm='rm -I'

eval "$(zoxide init bash)"
