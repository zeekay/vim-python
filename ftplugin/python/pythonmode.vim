if !exists("g:pythonmode_loaded")
python << EOF

# initialze rope
import sys, vim
sys.path.append(vim.eval("expand('<sfile>:p:h')")  + '/libs/')
import ropevim

def find_virtualenv(start):
    '''
    Work our way up trying to find enclosing virtualenv.
    '''
    def is_virtualenv(path):
        if os.path.exists(os.path.join(path, 'bin/activate_this.py')):
            return True
        return False

    while not is_virtualenv(path) and path != '/':
        path = os.path.abspath(os.path.join(path, '..'))

    if path != '/':
        return path

def PythonActivateVirtualenv():
    '''
    Activates virtualenv.
    '''
    venv = os.environ['VIRTUAL_ENV'] or find_virtualenv(os.path.dirname(vim.current.buffer.name))
    if not venv:
        return vim.command('echo "Virtualenv not found!"')

    sys.path.insert(0, venv)
    activate_this = os.path.join(venv, 'bin/activate_this.py')
    execfile(activate_this, dict(__file__=activate_this))
    # save env name to g:pythonvirtualenv var
    vim.command("let g:pythonvirtualenv = '%s'" % os.path.basename(venv))

# activate virtualenv
if 'VIRTUAL_ENV' in os.environ:
    PythonActivateVirtualenv()

# add cwd to syspath
sys.path.insert(0, os.path.dirname(vim.current.buffer.name))

# gf jumps to filename under cursor, point at import statement to jump to it
for p in sys.path:
    if os.path.isdir(p):
        vim.command(r"set path+=%s" % (p.replace(" ", r"\ ")))

EOF
let g:pythonmode_loaded = 1

function! s:PythonRunBuffer()
    pclose! " force preview window closed
    setlocal ft=python

" copy the buffer into a new window, then run that buffer through python
    silent %y a | below 10 new | silent put a | silent %!python -

" indicate the output window as the current previewwindow
    setlocal previewwindow ro nomodifiable nomodified
" nnoremap <buffer> <silent> q :bd<CR>
    nnoremap <silent> q :bd<CR>

" back into the original window
    winc p
endfunction

command! PythonRunBuffer call s:PythonRunBuffer()
command! PythonActivateVirtualenv py PythonActivateVirtualenv()

let g:ropevim_codeassist_maxfixes=10
let g:ropevim_guess_project=1
let g:ropevim_vim_completion=1
let g:ropevim_enable_autoimport=1
let g:ropevim_autoimport_modules = ["os", "shutil"]

imap <buffer><Nul> <M-/>
imap <buffer><C-Space> <M-/>
map <leader>r :PythonRunBuffer<cr>

endif

