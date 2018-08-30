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

function! s:GetWord(type) abort
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

function! s:WQ(string) abort 
    " Wrap with Quotes
    return "\'".a:string."\'"
endfunction

function! s:MakeInner(logmode, word) abort
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
        if (filename == 'index')
            let filepath = split(expand('%:r'), '/')
            let filename = filepath[-2] . '/' . filepath[-1]
        endif
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

function! s:MakeString(inner, isTrace) abort
    let string = 'console.'.(a:isTrace ? 'trace' : 'log')
    let string .= '('
    for prefix in g:js_fastlog_prefix
        let string .= s:WQ(prefix).', '
    endfor
    let string .= a:inner
    let string .= ')'

    let string .= (g:js_fastlog_use_semicolon ? ';' : '')
    return string
endfunction

function! jsfastlog#JsFastLog(type, logmode) abort
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

function! jsfastlog#GetLogModes() abort
    return s:logModes
endfunction
