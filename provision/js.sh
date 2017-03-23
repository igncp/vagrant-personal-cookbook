# js START

NODE_VERSION=6.3.0
if [ ! -f ~/.check-files/node ]; then
  echo "setup node with nodenv"
  cd ~
  if [ ! -d ~/.nodenv ]; then git clone https://github.com/nodenv/nodenv.git ~/.nodenv && cd ~/.nodenv && src/configure && make -C src; fi && \
    export PATH=$PATH:/home/$USER/.nodenv/bin && \
    eval "$(nodenv init -)" && \
    if [ ! -d ~/.nodenv/plugins/node-build ]; then git clone https://github.com/nodenv/node-build.git $(nodenv root)/plugins/node-build; fi && \
    if [ ! -d .nodenv/versions/$NODE_VERSION ]; then nodenv install $NODE_VERSION; fi && \
    nodenv global $NODE_VERSION && \
    mkdir -p ~/.check-files && touch ~/.check-files/node
  rm -f ~/install.sh
fi

install_node_modules() {
  for MODULE_NAME in "$@"; do
    if [ ! -d ~/.nodenv/versions/$NODE_VERSION/lib/node_modules/$MODULE_NAME ]; then
      echo "doing: npm i -g $MODULE_NAME"
      npm i -g $MODULE_NAME
    fi
  done
}

install_node_modules http-server diff-so-fancy eslint babel-eslint cloc yo eslint_d flow flow-cli

cat >> ~/.bashrc <<"EOF"
export PATH=$PATH:/home/$USER/.nodenv/bin
export PATH=$PATH:/home/$USER/.nodenv/versions/6.3.0/bin/
eval "$(nodenv init -)"
source <(npm completion)
EOF

cat >> ~/.bash_aliases <<"EOF"
alias Serve="http-server -c-1 -p 9000"
GitDiff() { git diff --color $@ | diff-so-fancy | less -R; }
# Fix coloring of mocha in some windows terminals
alias Mocha="./node_modules/.bin/mocha -c $@ > >(perl -pe 's/\x1b\[90m/\x1b[92m/g') 2> >(perl -pe 's/\x1b\[90m/\x1b[92m/g' 1>&2)"
EOF

cat > /tmp/clean-vim-js-syntax.sh <<"EOF"
sed -i 's|const |async await |' ~/.vim/bundle/vim-javascript-syntax/syntax/javascript.vim
sed -i 's|let var |let var const |' ~/.vim/bundle/vim-javascript-syntax/syntax/javascript.vim
sed -i 's|export from|export|' ~/.vim/bundle/vim-javascript-syntax/syntax/javascript.vim
sed -i 's|import public|import from public|' ~/.vim/bundle/vim-javascript-syntax/syntax/javascript.vim
echo "Changed vim javascript syntax"
EOF

# not installing vim-javascript as it doesn't work with rainbow
install_vim_package flowtype/vim-flow
install_vim_package jelera/vim-javascript-syntax "sh /tmp/clean-vim-js-syntax.sh"
install_vim_package kchmck/vim-coffee-script
install_vim_package leafgarland/typescript-vim
install_vim_package quramy/tsuquyomi
install_vim_package ternjs/tern_for_vim "cd ~/.vim/bundle/tern_for_vim; npm i"

cat >> ~/.vimrc <<"EOF"
" quick console.log
  let ConsoleMappingA="vnoremap <leader>kk yOconsole.log('a', a);<C-c>6hvpvi'yf'lllvp"
  let ConsoleMappingB='nnoremap <leader>kj iconsole.log("LOG POINT - <C-r>=fake#gen("nonsense")<CR>");<cr><c-c>'
  autocmd filetype javascript :exe ConsoleMappingA
  autocmd filetype javascript :exe ConsoleMappingB
  autocmd FileType typescript :exe ConsoleMappingA
  autocmd FileType typescript :exe ConsoleMappingB

" grep same indent props
  execute 'nnoremap <leader>ki ^hv0y' . g:GrepCF_fn . ' -o "^<c-r>"\w*:"<left>'

" term
  let g:tern_show_argument_hints = 'on_hold'
  let g:tern_show_signature_in_pum = 1
  autocmd FileType javascript nnoremap <silent> <buffer> gb :TernDef<CR><Paste>

" run eslint over file
  nnoremap <silent> <leader>kb :!eslint_d --fix %<cr>:e<cr>

" js linters
  let g:syntastic_javascript_checkers = ['flow', 'eslint']
  let g:syntastic_javascript_eslint_exec = 'eslint_d'
  let g:syntastic_typescript_checkers = ['tsc', 'tslint']
  let g:flow#enable = 0

 autocmd BufNewFile,BufRead *.js
	\ call neosnippet#commands#_source("/home/vagrant/.vim/bundle/vim-snippets/snippets/javascript.es6.react.snippets")
EOF

cat > /tmp/js-and-ts-snippets <<"EOF"
snippet ide
  if (${0}) {
    debugger;
  }
snippet ck
  console.log("${0:}", $0);
snippet cj
  console.log("LOG POINT - ${0:}");
snippet des
  describe("${1:}", () => {
    ${0}
  });
snippet desf
  describe("${1:}", function() {
    ${0}
  });
snippet bef
  beforeEach(() => {
    ${0}
  });
snippet it
  it("${1:}", () => {
    ${0}
  });
snippet exp
  expect(${1:}).to.${0};
snippet ii
  import {
    ${1},
  } from "${2}";
EOF
cat /tmp/js-and-ts-snippets > ~/.vim-snippets/javascript.snippets
cat /tmp/js-and-ts-snippets > ~/.vim-snippets/typescript.snippets

install_node_modules markdown-toc
cat >> ~/.bash_aliases <<"EOF"
alias MarkdownTocRecursive='find . ! -path "*.git*" -name "*.md" | xargs -I {} markdown-toc -i {}'
EOF
cat > ~/.vim-snippets/markdown.snippets <<"EOF"
snippet toc
  <!-- toc -->
EOF

install_node_modules yarn yarn-completions
cat >> ~/.bash_sources <<"EOF"
source_if_exists ~/.nodenv/versions/6.3.0/lib/node_modules/yarn-completions/node_modules/tabtab/.completions/yarn.bash
EOF

install_node_modules gnomon
echo 'C-j: "\C-atime \C-e | gnomon \C-m"' >> ~/.inputrc

# js END
