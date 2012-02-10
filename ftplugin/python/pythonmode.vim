if !exists("g:pythonmode_loaded")
python << EOF

# initialze rope
import sys, vim
sys.path.append(vim.eval("expand('<sfile>:p:h')")  + '/libs/')
import ropevim

# activate virtualenv
ve_dir = os.environ['VIRTUAL_ENV']
ve_dir in sys.path or sys.path.insert(0, ve_dir)
activate_this = os.path.join(os.path.join(ve_dir, 'bin'), 'activate_this.py')
execfile(activate_this, dict(__file__=activate_this))

EOF
let g:pythonmode_loaded = 1
endif

" RopeVim settings
let g:ropevim_codeassist_maxfixes=10
let g:ropevim_guess_project=1
let g:ropevim_vim_completion=1
let g:ropevim_enable_autoimport=1
let g:ropevim_autoimport_modules = ["os", "shutil"]

" Keys
imap <buffer><Nul> <M-/>
imap <buffer><C-Space> <M-/>
