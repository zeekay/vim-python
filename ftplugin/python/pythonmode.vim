if !exists("g:pythonmode_loaded")
    let g:pythonmode_loaded = 1
else
    finish
endif

if !exists('g:pythonmode_enable_rope')
   let g:pythonmode_enable_rope = 0
endif

if !exists('g:pythonmode_enable_rope')
   let g:pythonmode_enable_rope = 0
endif

if !exists('g:virtualenv_directory')
    let g:virtualenv_directory = 0
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

def find_virtualenv(path):
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

def virtualenv_activate(venv=None):
    '''
    Activates virtualenv.
    '''
    venv_dir = vim.eval('expand(g:virtualenv_directory)') or vim.eval('getcwd()')
    if venv:
        venv = os.path.join(venv_dir, venv)
    else:
        venv = find_virtualenv(venv_dir)

    if not os.path.exists(venv):
        return vim.command('echo "Virtualenv not found!"')

    sys.path.insert(0, venv)
    activate_this = os.path.join(venv, 'bin/activate_this.py')
    execfile(activate_this, dict(__file__=activate_this))
    # save env name to g:pythonvirtualenv var
    os.environ['VIRTUAL_ENV'] = os.path.basename(venv)

# activate virtualenv
if 'VIRTUAL_ENV' in os.environ:
    virtualenv_activate(os.environ['VIRTUAL_ENV'])
EOF

command! -nargs=? VirtualenvActivate py virtualenv_activate(<f-args>)

function! s:PythonRunBuffer(...)
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

command! -nargs=* PythonRunBuffer call s:PythonRunBuffer(<args>)

map <leader>r :PythonRunBuffer<cr>

if g:pythonmode_enable_rope
    let g:ropevim_codeassist_maxfixes=10
    let g:ropevim_guess_project=1
    let g:ropevim_vim_completion=1
    let g:ropevim_enable_autoimport=1
    let g:ropevim_autoimport_modules = ["os", "shutil"]
    imap <buffer><Nul> <M-/>
    imap <buffer><C-Space> <M-/>
endif
