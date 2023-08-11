#
# ~/.bashrc
#

export GTK_THEME=Adwaita:dark
export GTK_RC_FILES=/usr/share/themes/Adwaita-dark/gtk-2.0/gtkrc
export QT_STYLE_OVERRIDE=adwaita-dark

# If not running interactively, don't do anything
[[ $- != *i* ]] && return


alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
