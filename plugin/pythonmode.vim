function VirtualEnvStatusline()
    if $VIRTUAL_ENV != ''
        return fnamemodify($VIRTUAL_ENV, ':t')
    else
        return ''
    endif
endfunction
