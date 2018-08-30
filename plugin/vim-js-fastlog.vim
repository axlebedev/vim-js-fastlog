if exists("g:loaded_js_fastlog") || &cp || v:version < 700
    finish
endif
let g:loaded_js_fastlog = 1

let g:js_fastlog_prefix = get(g:, 'js_fastlog_prefix', [])
let g:js_fastlog_use_semicolon = get(g:, 'js_fastlog_use_semicolon', 1)

let s:logModes = jsfastlog#GetLogModes()

function! JsFastLog_simple(type)
    call jsfastlog#JsFastLog(a:type, s:logModes.simple)
endfunction

function! JsFastLog_JSONstringify(type)
    call jsfastlog#JsFastLog(a:type, s:logModes.jsonStringify)
endfunction

function! JsFastLog_variable(type)
    call jsfastlog#JsFastLog(a:type, s:logModes.showVar)
endfunction

function! JsFastLog_function(type)
    call jsfastlog#JsFastLog(a:type, s:logModes.funcTimestamp)
endfunction

function! JsFastLog_string(type)
    call jsfastlog#JsFastLog(a:type, s:logModes.string)
endfunction

function! JsFastLog_prevToThis(type)
    call jsfastlog#JsFastLog(a:type, s:logModes.prevToThis)
endfunction

function! JsFastLog_thisToNext(type)
    call jsfastlog#JsFastLog(a:type, s:logModes.thisToNext)
endfunction

function! JsFastLog_separator()
    call jsfastlog#JsFastLog('', s:logModes.separator)
endfunction

function! JsFastLog_lineNumber()
    call jsfastlog#JsFastLog('', s:logModes.lineNumber)
endfunction

" nnoremap <leader>l :set operatorfunc=JsFastLog_simple<cr>g@
" vnoremap <leader>l :<C-u>call JsFastLog_simple(visualmode())<cr>
"
" nnoremap <leader>ll :set operatorfunc=JsFastLog_JSONstringify<cr>g@
" vnoremap <leader>ll :<C-u>call JsFastLog_JSONstringify(visualmode())<cr>
"
" nnoremap <leader>lk :set operatorfunc=JsFastLog_variable<cr>g@
" vnoremap <leader>lk :<C-u>call JsFastLog_variable(visualmode())<cr>
"
" nnoremap <leader>ld :set operatorfunc=JsFastLog_function<cr>g@
" vnoremap <leader>ld :<C-u>call JsFastLog_function(visualmode())<cr>
"
" nnoremap <leader>ls :set operatorfunc=JsFastLog_string<cr>g@
" vnoremap <leader>ls :<C-u>call JsFastLog_string(visualmode())<cr>
"
" nnoremap <leader>lpp :set operatorfunc=JsFastLog_prevToThis<cr>g@
" vnoremap <leader>lpp :<C-u>call JsFastLog_prevToThis(visualmode())<cr>
"
" nnoremap <leader>lpn :set operatorfunc=JsFastLog_thisToNext<cr>g@
" vnoremap <leader>lpn :<C-u>call JsFastLog_thisToNext(visualmode())<cr>
"
" nnoremap <leader>lss :call JsFastLog_separator()<cr>
" nnoremap <leader>lsn :call JsFastLog_lineNumber()<cr>
