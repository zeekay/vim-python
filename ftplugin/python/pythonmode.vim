if !exists("g:pythonmode_loaded")
    let g:pythonmode_loaded = 1
else
    finish
endif

if !exists('g:pythonmode_enable_rope')
   let g:pythonmode_enable_rope = 0
endif

python << EOF
import os
import sys
import vim

# add cwd to syspath
sys.path.insert(0, vim.eval('getcwd()'))

# Add paths in sys.path to vim path
for p in sys.path:
    if os.path.isdir(p):
        vim.command(r"set path+=%s" % (p.replace(" ", r"\ ")))

if vim.eval('g:pythonmode_enable_rope'):
    # Enable ropevim
    sys.path.append(vim.eval("expand('<sfile>:p:h')")  + '/libs/')
    import ropevim
EOF

function! s:RunBuffer(...)
    let fn = expand('%:p')
    if fn == ''
        echoerr 'Save buffer to file first'
        return
    endif

    " setup python command so virtualenv gets activated if necessary
    if exists('g:virtualenv_name')
        let cmd = 'source '.g:virtualenv_directory.'/'.g:virtualenv_name.'/bin/activate && python '
    else
        let cmd = 'python '
    endif

    " handle arguments to python script
    if a:0
        let args = ' '.join(a:000)
    else
        let args = ''
    endif

    " write file out
    exe 'w'

    " create new preview window and read results into it
    pclose! | botright 10 new
    try
        silent exe '0r! '.cmd.' '.fn.' '.args
    catch /.*/
        close
        echoerr 'Command failed'
    endtry
    redraw
    normal gg
    setlocal buftype=nofile bufhidden=delete noswapfile nowrap previewwindow
    wincmd p
endfunction

command! -nargs=* RunBuffer call s:RunBuffer(<args>)

map <leader>r :RunBuffer<cr>

if g:pythonmode_enable_rope
    let g:ropevim_codeassist_maxfixes=10
    let g:ropevim_guess_project=1
    let g:ropevim_vim_completion=1
    let g:ropevim_enable_autoimport=1
    let g:ropevim_autoimport_modules = ["os", "shutil"]
    imap <buffer><Nul> <M-/>
    imap <buffer><C-Space> <M-/>
endif


