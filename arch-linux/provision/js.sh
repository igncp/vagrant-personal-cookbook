# js START

# Dependencies:
# - after: vim-extra.sh

NODE_VERSION=10.16.0

if ! type node > /dev/null 2>&1 ; then
  (asdf plugin add nodejs || true)
  bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring

  asdf install nodejs "$NODE_VERSION"
  asdf global nodejs "$NODE_VERSION"
fi

install_node_modules() {
  for MODULE_NAME in "$@"; do
    if [ ! -d "$HOME/.asdf/installs/nodejs/$NODE_VERSION/.npm/lib/node_modules/$MODULE_NAME" ]; then
      echo "doing: npm i -g $MODULE_NAME"
      npm i -g $MODULE_NAME
    fi
  done
}

install_node_modules http-server diff-so-fancy eslint babel-eslint cloc eslint_d

cat >> ~/.vimrc <<"EOF"
  function! DisplayPrettyFlowType()
    let column = col('.')
    let line = line(".")
    let file_path = expand('%:p')

    let cmd = "printf '// @flow\n\n' > /tmp/flow_type.js"
    let cmd = cmd . "; ./node_modules/.bin/flow type-at-pos  " . file_path . " " . line . " " . column . " >> /tmp/flow_type.js"
    let cmd = cmd . "; sed -i '$ d' /tmp/flow_type.js"
    let cmd = cmd . "; prettier --write --parser flow /tmp/flow_type.js"

    call system(cmd)
    execute ":-tabnew /tmp/flow_type.js"
  endfunction
  autocmd filetype javascript :exe 'nnoremap <leader>jd :call DisplayPrettyFlowType()<cr>'
EOF

cat >> ~/.bash_aliases <<"EOF"
Serve() { PORT="$2"; http-server -c-1 -p "${PORT:=9000}" $1; }
# Fix coloring of mocha in some windows terminals
alias Mocha="./node_modules/.bin/mocha -c $@ > >(perl -pe 's/\x1b\[90m/\x1b[92m/g') 2> >(perl -pe 's/\x1b\[90m/\x1b[92m/g' 1>&2)"
EOF

git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
git config --global color.diff-highlight.oldNormal "red bold"
git config --global color.diff-highlight.oldHighlight "red bold 52"
git config --global color.diff-highlight.newNormal "green bold"
git config --global color.diff-highlight.newHighlight "green bold 22"

cat > /tmp/clean-vim-js-syntax.sh <<"EOF"
sed -i 's|const |async await |' ~/.vim/bundle/vim-javascript-syntax/syntax/javascript.vim
sed -i 's|let var |let var const |' ~/.vim/bundle/vim-javascript-syntax/syntax/javascript.vim
sed -i 's|export from|export|' ~/.vim/bundle/vim-javascript-syntax/syntax/javascript.vim
sed -i 's|import public|import from type public|' ~/.vim/bundle/vim-javascript-syntax/syntax/javascript.vim
echo "Changed vim javascript syntax"
EOF

# not installing vim-javascript as it doesn't work with rainbow
install_vim_package ternjs/tern_for_vim "cd ~/.vim/bundle/tern_for_vim; npm i"
install_vim_package flowtype/vim-flow
install_vim_package jelera/vim-javascript-syntax "sh /tmp/clean-vim-js-syntax.sh"
install_vim_package samuelsimoes/vim-jsx-utils
install_vim_package posva/vim-vue

cat >> ~/.vimrc <<"EOF"
" quick console.log (maybe used by typescript later on)
  let ConsoleMappingA="vnoremap <leader>kk yOconsole.log('a', a);<C-c>6hvpvi'yf'lllvp"
  let ConsoleMappingB='nnoremap <leader>kj iconsole.log("LOG POINT - <C-r>=fake#gen("nonsense")<CR>");<cr><c-c>'
  autocmd filetype javascript,vue :exe ConsoleMappingA
  autocmd filetype javascript,vue :exe ConsoleMappingB

" grep same indent props
  execute 'nnoremap <leader>ki ^hv0y' . g:GrepCF_fn . ' -o "^<c-r>"\w*:"<left>'

" term
  let g:tern_show_argument_hints = 'on_hold'
  let g:tern_show_signature_in_pum = 1
  autocmd FileType javascript nnoremap <silent> <buffer> gb :TernDef<CR><Paste>

" run eslint or prettier over file
  autocmd filetype javascript,vue :exe "nnoremap <silent> <leader>kb :!eslint_d --fix %<cr>:e<cr>"
  autocmd filetype javascript,vue :exe "nnoremap <silent> <leader>kB :!npx prettier --write %<cr>:e<cr>"
  autocmd filetype javascript,vue :exe "vnoremap <silent> <leader>kB :'<,'>PrettierFragment<cr>"
  autocmd filetype javascript,vue :exe "nnoremap <silent> <c-a> :update<cr>:!eslint_d --fix %<cr>:e<cr>"
  autocmd filetype javascript,vue :exe "inoremap <silent> <c-a> <c-c>:update<cr>:!eslint_d --fix %<cr>:e<cr>"
  autocmd filetype html :exe "nnoremap <silent> <leader>kB :!npx prettier --write %<cr>:e<cr>"
  " --tab-width 4 is for BitBucket lists
  autocmd filetype markdown :exe "nnoremap <silent> <leader>kB :!npx prettier --write --tab-width 4 %<cr>:e<cr>"

" js linters
  let g:syntastic_javascript_checkers = ['flow', 'eslint']
  let g:syntastic_javascript_eslint_exec = 'eslint_d'
  let g:flow#enable = 0

 autocmd BufNewFile,BufRead *.js
	\ call neosnippet#commands#_source("/home/igncp/.vim/bundle/vim-snippets/snippets/javascript-es6-react.snippets")

" jsx utils
  nnoremap <leader>jx $i<left><space><cr><up><c-c>:call JSXEachAttributeInLine()<CR>:%s/\s\+$<CR><c-o>A<cr><tab>
EOF

install_node_modules markdown-toc
cat >> ~/.bash_aliases <<"EOF"
alias MarkdownTocRecursive='find . ! -path "*.git*" -name "*.md" | xargs -I {} markdown-toc -i {}'
EOF

cat > ~/.js-tests-specs-displayer <<"EOF"
#!/usr/bin/env bash
# this file is generated from the provision, changes will be overwritten
FILE_PATH="$1";
source ~/hhighlighter/h.sh
export H_COLORS_FG="green,blue"
grep -E "it\(|describe\(|it\.only\(|describe\.only\(" "$FILE_PATH" |
  sed -r 's| \(\) => \{$||; s| async$||; s|,$||; s|it.only\(|it(|; s|describe\.only\(|describe(|' |
  h "describe\((.*)" "it\((.*)" |
  sed "s|describe(||; s|it(||;" > /tmp/tests-specs
sed -i '1i'"$FILE_PATH\n" /tmp/tests-specs
echo "" >> /tmp/tests-specs
less -R /tmp/tests-specs
EOF
chmod +x ~/.js-tests-specs-displayer
cat >> ~/.vimrc <<"EOF"
  autocmd filetype javascript :exe 'nnoremap <leader>zt :-tabnew\|te ~/.js-tests-specs-displayer <c-r>=expand("%:p")<cr><cr>'

  function! ToggleItOnly()
    execute "normal! ?it(\\|it.only(\<cr>\<right>\<right>"
    let current_char = nr2char(strgetchar(getline('.')[col('.') - 1:], 0))
    if current_char == "."
      execute "normal! v4l\<del>"
    else
      execute "normal! i.only\<c-c>"
    endif
    execute "normal! \<c-o>"
  endfunction
  autocmd filetype javascript :exe 'nnoremap <leader>zo :call ToggleItOnly()<cr>'

  nnoremap <leader>BT :let g:Fast_grep_opts='--exclude-dir="__tests__" --exclude-dir="__integration__" -i'<left>
EOF

echo "./node_modules/.bin/jest">> ~/.bookmarked-commands

cat >> ~/.vimrc <<"EOF"
function! g:RunCtrlPWithFilterInNewTab(query)
  let g:ctrlp_default_input=a:query
  execute '-tabnew'
  execute 'CtrlP'
  let g:ctrlp_default_input=''
endfunction
EOF

add_special_vim_map "cpfat" $':call RunCtrlPWithFilterInNewTab(\'<c-r>=expand("%:t:r")<cr>test\')<cr>' 'ctrlp filename adding test'
add_special_vim_map "cpfrt" $':call RunCtrlPWithFilterInNewTab(\'<c-r>=expand("%:t:r")<cr><bs><bs><bs><bs><bs>\')<cr>' 'ctrlp filename removing test'
add_special_vim_map "ctit" $'? it(<cr>V$%y$%o<cr><c-c>Vpf(2l' 'test copy it test case content'
add_special_vim_map "ctde" $'? describe(<cr>V$%y$%o<cr><c-c>Vpf(2l' 'test copy describe test content'
add_special_vim_map "eeq" $'iXexpectEqual<c-o>:call feedkeys("<c-l>", "t")<cr>' 'test expect toEqual'
add_special_vim_map "sjsfun" "v/[^,] {<cr><right>%" "select js function"
add_special_vim_map "djsfun" "v/[^,] {<cr><right>%d" "cut js function"
add_special_vim_map "jsjmi" "a.mockImplementation(() => )<left>" "jest mock implementation"
add_special_vim_map 'tjmvs' 'I<c-right><right><c-c>viwy?describe(<cr>olet <c-c>pa;<c-c><c-o><left>v_<del>' \
  'jest move variable outside of it'
add_special_vim_map "titr" $'_ciwconst<c-c>/from<cr>ciw= require(<del><c-c>$a)<c-c>V:<c-u>%s/\%V\C;//g<cr>' \
  'transform import to require'
add_special_vim_map "jimc" "a.mock.calls<c-c>" "jest instert mock calls"
add_special_vim_map "jimi" "a.mockImplementation(() => )<left>" "jest instert mock implementation"
add_special_vim_map "jirv" "a.mockReturnValue()<left>" "jest instert mock return value"
add_special_vim_map "ftmakeexact" $'_f{a\|<c-c><left>%i\|' 'flowtype make exact type'
add_special_vim_map "ftshowerrors" $':-tabnew\|te flow <c-r>=expand("%")<cr> --color always \| less -R<cr>' 'flowtype display errors'
add_special_vim_map 'ftcrefuntype' 'viwyi<c-right><left>: T_<c-c>pviwyO<c-c>Otype <c-c>pa = () => <c-c>4hi' 'flowtype create function type'
add_special_vim_map 'ftcasttoany' 'gvdi()<c-c><left>pa: any<c-c>' 'flowtype cast to any'
add_special_vim_map "jrct" "gv:<c-u>%s/\%V\C+//ge<cr>:<c-u>%s/\%V\CObject //ge<cr>:<c-u>%s/\%V\CArray //ge<cr>:<c-u>%s/\%V\C\[Fun.*\]/expect.any(Function)/ge<cr>" \
  "jest replace copied text from terminal"

cat >> ~/.vim-macros <<"EOF"

" Convert jsx prop to object property
_f=i\<del>: \<c-c>\<right>%s,\<c-c>``s\<c-c>``j

" Create test property
_f:v$\<left>\<del>A: \<c-c>_viwyA''\<c-c>\<left>paValue\<c-c>A,\<c-c>_\<down>

" wrap type object in tag
i<\<c-c>\<right>%a>\<c-c>\<left>%\<left>
EOF

# requires jq by default
cat >> ~/.vimrc <<"EOF"
let g:SpecialImports_Cmd_Default_End=' | sed -r "s|^([^.])|./\1|"'
  \ . ' | grep -E "(\.js|\.s?css)$" | grep -v "__tests__" | sed "s|\.js$||; s|/index$||"'
  \ . ' > /tmp/vim_special_import;'
  \ . ' jq ".dependencies,.devDependencies | keys" package.json | grep -o $"\".*" | sed $"s|\"||g; s|,||"'
  \ . ' >> /tmp/vim_special_import) && cat /tmp/vim_special_import'
let g:SpecialImports_Cmd_Rel_Default='(find ./src -type f | xargs realpath --relative-to="$(dirname <CURRENT_FILE>)"'
  \ . g:SpecialImports_Cmd_Default_End
let g:SpecialImports_Cmd_Full_Default='(DIR="./src";  find "$DIR" -type f | xargs realpath --relative-to="$DIR"'
  \ . g:SpecialImports_Cmd_Default_End . ' | sed "s|^\.|#|"'
let g:SpecialImports_Cmd=g:SpecialImports_Cmd_Full_Default

function! s:SpecialImportsSink(selected)
  execute "norm! o \<c-u>import  from '". a:selected . "'\<c-c>I\<c-right>"
  call feedkeys('i', 'n')
endfunction

function! SpecialImports()
  let l:final_cmd = substitute(g:SpecialImports_Cmd, "<CURRENT_FILE>", expand('%:p'), "")
  let file_content = system(l:final_cmd)
  let source_list = split(file_content, '\n')
  let options_dict = {
    \ 'options': ' --prompt "File (n)> " --ansi --no-hscroll --nth 1,..',
    \ 'source': source_list,
    \ 'sink': function('s:SpecialImportsSink')}

  call fzf#run(options_dict)
endfunction

nnoremap <leader>jss :call SpecialImports()<cr>
nnoremap <leader>jsS :let g:SpecialImports_Cmd='<c-r>=g:SpecialImports_Cmd<cr>'<home><c-right><c-right><right>
nnoremap <leader>jsQ :let g:SpecialImports_Cmd='<c-r>=g:SpecialImports_Cmd_Full_Default<cr>'<home><c-right><c-right><right>
nnoremap <leader>jsW :let g:SpecialImports_Cmd='<c-r>=g:SpecialImports_Cmd_Rel_Default<cr>'<home><c-right><c-right><right>
EOF

cat >> ~/.vimrc <<"EOF"
let g:ale_linters = {
\'javascript': ['flow', 'eslint'],
\}
let g:ale_fixers = {
\'javascript': ['eslint'],
\}
EOF

install_vim_package prettier/vim-prettier

install_node_modules diff2html-cli

cat >> ~/.bash_aliases <<"EOF"
Diff2Html() {
  mkdir -p /tmp/diff-result
  # Serve is only useful in VM where there is no automatic open
  diff2html -F /tmp/diff-result/index.html "$@" && Serve /tmp/diff-result
}
EOF

cat >> ~/.vimrc <<"EOF"
autocmd filetype vue :exe 'nnoremap <leader>jres /<script <cr>zz'
autocmd filetype vue :exe 'nnoremap <leader>jreS /<\/script<cr>zz'
autocmd filetype vue :exe 'nnoremap <leader>jrec /^export.*class<cr>zz'
EOF

# js-extras available

# ts available

# js END
