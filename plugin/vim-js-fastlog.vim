function! s:GetWord(type)
    let saved_unnamed_register = @@

    if (a:type ==# 'v')
        execute "normal! `<v`>y"
    elseif (a:type ==# 'char')
        execute "normal! `[v`]y"
    else
        return ''
    endif

    let word = escape(@@, "'")
    let @@ = saved_unnamed_register
    return word
endfunction

let s:logModes = {
\    'simple': 1,
\    'jsonStringify': 2,
\    'showVar': 3,
\    'funcTimestamp': 4,
\}

echom s:logModes.simple

function! s:JsFastLog(type, logmode)
    let word = s:GetWord(a:type)

    if (match(word, '\v\S') == -1) " check if there is empty (whitespace-only) string
        execute "normal! aconsole.log();\<esc>hh"
    elseif (a:logmode ==# s:logModes.simple) " simple: 'var' => 'console.log(var);'
        put ='console.log('.word.');'
        -delete _ | normal! ==f(l
    elseif (a:logmode ==# s:logModes.jsonStringify) " JSON.stringify: 'var' => 'console.log('var='+JSON.stringify(var));'
        put ='console.log('''.word.'='' + JSON.stringify('.word.'));'
        -delete _ | normal! ==f(l
    elseif (a:logmode ==# s:logModes.showVar)
        put ='console.log('''.word.'='', '.word.');'
        -delete _ | normal! ==f(l
    elseif (a:logmode ==# s:logModes.funcTimestamp)
        let filename = expand('%:t:r')
        put ='console.log(Date.now() % 10000 + '''.filename.'::'.word.''');'
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

nnoremap <leader>l :set operatorfunc=JsFastLog_simple<cr>g@
vnoremap <leader>l :<C-u>call JsFastLog_simple(visualmode())<cr>

nnoremap <leader>ll :set operatorfunc=JsFastLog_JSONstringify<cr>g@
vnoremap <leader>ll :<C-u>call JsFastLog_JSONstringify(visualmode())<cr>

nnoremap <leader>lk :set operatorfunc=JsFastLog_variable<cr>g@
vnoremap <leader>lk :<C-u>call JsFastLog_variable(visualmode())<cr>

nnoremap <leader>ld :set operatorfunc=JsFastLog_function<cr>g@
vnoremap <leader>ld :<C-u>call JsFastLog_function(visualmode())<cr>
