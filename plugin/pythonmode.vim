" This is so powerline uses our function for the statusline.
if !exists('g:virtualenv_loaded')
    let g:virtualenv_loaded = 1
endif

function! VirtualEnvStatusline()
    if $VIRTUAL_ENV != ''
        return fnamemodify($VIRTUAL_ENV, ':t')
    else
        return ''
    endif
endfunction
