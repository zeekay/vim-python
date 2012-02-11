if !exists("g:vimpythonmode_loaded")
    let g:vimpythonmode_loaded = 1
else
    finish
endif

python << EOF
import os
import sys
import vim

# add ropevim libs to sys.path
sys.path.append(vim.eval("expand('<sfile>:p:h')")  + '/libs/')
import ropevim

# add cwd to syspath
sys.path.insert(0, vim.eval('getcwd()'))

# Add paths in sys.path to vim path
# for p in sys.path:
#     if os.path.isdir(p):
#         vim.command(r"set path+=%s" % (p.replace(" ", r"\ ")))
EOF

function! s:PythonRunBuffer()
    if exists('g:virtualenv_name')
        let cmd = 'source '.g:virtualenv_directory.'/'.g:virtualenv_name.'/bin/activate && python '.expand('%:p')
    else
        let cmd = 'python '.expand('%:p')
    endif

    pclose
    botright 10 new
    setlocal buftype=nofile bufhidden=delete noswapfile nowrap previewwindow
    redraw
    try
        silent exec '0r!'.cmd
    catch /.*/
        close
        echoerr 'Command fail: '.cmd
    endtry
    redraw
    normal gg
    wincmd p
endfunction

command! PythonRunBuffer call s:PythonRunBuffer()

let g:ropevim_codeassist_maxfixes=10
let g:ropevim_guess_project=1
let g:ropevim_vim_completion=1
let g:ropevim_enable_autoimport=1
let g:ropevim_autoimport_modules = ["os", "shutil"]

imap <buffer><Nul> <M-/>
imap <buffer><C-Space> <M-/>
map <leader>r :PythonRunBuffer<cr>
