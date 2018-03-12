if exists("g:loaded_js_fastlog") || &cp || v:version < 700
    finish
endif
let g:loaded_js_fastlog = 1

let g:js_fastlog_prefix = get(g:, 'js_fastlog_prefix', '')
let g:js_fastlog_use_semicolon = get(g:, 'js_fastlog_use_semicolon', 1)

let s:logModes = {
\    'simple': 1,
\    'jsonStringify': 2,
\    'showVar': 3,
\    'funcTimestamp': 4,
\    'string': 5,
\    'prevToThis': 6,
\    'thisToNext': 7,
\    'separator': 8,
\    'lineNumber': 9,
\}

function! s:GetWord(type)
    let saved_unnamed_register = @@

    if (a:type ==# 'v')
        execute "normal! `<v`>y"
    elseif (a:type ==# 'char')
        execute "normal! `[v`]y"
    else
        return ''
    endif

    let word = @@
    let @@ = saved_unnamed_register
    return word
endfunction

function! s:WQ(string) " Wrap with Quotes
    return "\'".a:string."\'"
endfunction

function! s:MakeInner(logmode, word)
    let inner = a:word
    let escapedWord = escape(a:word, "'")
    if (a:logmode ==# s:logModes.string) " string: 'var' => 'console.log('var');'
        let inner = s:WQ(escapedWord)

    elseif (a:logmode ==# s:logModes.jsonStringify) " JSON.stringify: 'var' => 'console.log('var='+JSON.stringify(var));'
        let inner = s:WQ(escapedWord.'=')." + JSON.stringify(".a:word.")"

    elseif (a:logmode ==# s:logModes.showVar)
        let inner = s:WQ(escapedWord.'=').', '.a:word

    elseif (a:logmode ==# s:logModes.funcTimestamp)
        let filename = expand('%:t:r')
        let inner = 'Date.now() % 10000, '.s:WQ(filename.':'.line('.').' '.escapedWord)

    elseif (a:logmode ==# s:logModes.prevToThis)
        let inner = s:WQ(escapedWord.': ').', prevProps.'.a:word.", \' => \', this.props.".a:word

    elseif (a:logmode ==# s:logModes.thisToNext)
        let inner = s:WQ(escapedWord.': ').', this.props.'.a:word.", \' => \', nextProps.".a:word

    elseif (a:logmode ==# s:logModes.separator)
        let inner = s:WQ(' ========================================')

    elseif (a:logmode ==# s:logModes.lineNumber)
        let filename = expand('%:t:r')
        let inner = s:WQ(filename.':'.line('.'))

    endif
    return inner
endfunction

function! s:MakeString(inner, isTrace)
    let string = 'console.'.(a:isTrace ? 'trace' : 'log')
    let string .= '('
    if (!empty(g:js_fastlog_prefix))
        let string .= s:WQ(g:js_fastlog_prefix).', '
    endif
    let string .= a:inner
    let string .= ')'

    let string .= (g:js_fastlog_use_semicolon ? ';' : '')
    return string
endfunction

function! s:JsFastLog(type, logmode)
    if (a:type ==# 'V' || a:type ==# '')
        normal! O// js-fastlog: sorry, but I work only with charwise selection
        return
    endif

    let word = s:GetWord(a:type)

    let wordIsEmpty = match(word, '\v\S') == -1
    if (a:logmode !=# s:logModes.separator
      \ && a:logmode !=# s:logModes.lineNumber
      \ && wordIsEmpty)
        execute "normal! aconsole.log();\<esc>hh"
    else
        put = s:MakeString(s:MakeInner(a:logmode, word), 0)

        if (a:logmode ==# s:logModes.funcTimestamp
          \ || a:logmode ==# s:logModes.separator)
            normal! ==f(l
        else
            -delete _ | normal! ==f(l
        endif
    endif
endfunction

function! JsFastLog_simple(type)
    call s:JsFastLog(a:type, s:logModes.simple)
endfunction

function! JsFastLog_JSONstringify(type)
    call s:JsFastLog(a:type, s:logModes.jsonStringify)
endfunction

function! JsFastLog_variable(type)
    call s:JsFastLog(a:type, s:logModes.showVar)
endfunction

function! JsFastLog_function(type)
    call s:JsFastLog(a:type, s:logModes.funcTimestamp)
endfunction

function! JsFastLog_string(type)
    call s:JsFastLog(a:type, s:logModes.string)
endfunction

function! JsFastLog_prevToThis(type)
    call s:JsFastLog(a:type, s:logModes.prevToThis)
endfunction

function! JsFastLog_thisToNext(type)
    call s:JsFastLog(a:type, s:logModes.thisToNext)
endfunction

function! JsFastLog_separator()
    call s:JsFastLog('', s:logModes.separator)
endfunction

function! JsFastLog_lineNumber()
    call s:JsFastLog('', s:logModes.lineNumber)
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
