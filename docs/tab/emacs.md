# TAB & Emacs

- Run a world from within Emacs by (from a buffer in its `worlds/<name>-tab` directory) `M-x compile`, press ENTER, then `make -k load TAB_ROOT=~/tab`
- Connect with `M-x telnet`, ENTER, `localhost 4242`

Bonus: emsenn has [eir emacsen configuration](https://gist.github.com/emsenn/c0bc1d5240dfa4fc0e17ce9624a7de9c) on Github, you can get it locally with: `curl -o ~/.emacs.d/init.el https://gist.githubusercontent.com/emsenn/c0bc1d5240dfa4fc0e17ce9624a7de9c/raw/75a386f4ebb01112557a4185e5e95e839b938c4e/init.el`
