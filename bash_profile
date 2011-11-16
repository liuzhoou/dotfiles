if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

## Source any local additions
if [ -f ~/.bash_local ]; then
  . ~/.bash_local
fi

export PATH=/Applications/SenchaSDKTools-2.0.0-Developer-Preview:$PATH

export PATH=/Applications/SenchaSDKTools-2.0.0-Developer-Preview/command:$PATH

export PATH=/Applications/SenchaSDKTools-2.0.0-Developer-Preview/jsbuilder:$PATH
