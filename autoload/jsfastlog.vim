vim9script

var logModes = {
    'simple': 1,
    'jsonStringify': 2,
    'showVar': 3,
    'funcTimestamp': 4,
    'string': 5,
    'separator': 8,
    'lineNumber': 9,
    'traceCollapsed': 10,
}

def GetSelectionColumns(): dict<number>
    var pos1 = getcharpos('v')[2]
    var pos2 = getcharpos('.')[2]
    return {
        start: min([pos1, pos2]),
        end: max([pos1, pos2]),
    }
enddef

def GetWord(): string
    if (mode() == 'n')
        return expand('<cword>')
    endif

    var sel = GetSelectionColumns()
    # "- 1" because sel indexes start from 1, getline starts from 0
    return getline('.')[sel.start - 1 : sel.end - 1]
enddef

def WQ(s: string): string
    # Wrap with Quotes
    return "\'" .. s .. "\'"
enddef

def MakeInner(logmode: number, word: string): string
    echom 'MakeInner(' .. logmode .. ', ' .. word .. ')'
    var inner = word
    var escapedWord = escape(word, "'")
    if (logmode ==# logModes.string) # string: 'var' => 'console.log('var');'
        return WQ(escapedWord)
    endif

    if (logmode ==# logModes.jsonStringify) # JSON.stringify: 'var' => 'console.log('var='+JSON.stringify(var));'
        return WQ(escapedWord .. '=') .. " + JSON.stringify(" .. word .. ")"
    endif

    if (logmode ==# logModes.showVar)
        return WQ(escapedWord .. '=') .. ', ' .. word
    endif

    if (logmode ==# logModes.funcTimestamp)
        var filename = expand('%:t:r')
        if (filename == 'index')
            var filepath = split(expand('%:r'), '/')
            filename = filepath[-2] .. '/' .. filepath[-1]
        endif
        return 'Date.now() % 10000, ' .. WQ(filename .. ':' .. line('.') .. ' ' .. escapedWord)
    endif

    if (logmode ==# logModes.separator)
        return WQ(' ========================================')
    endif

    if (logmode ==# logModes.lineNumber)
        var filename = expand('%:t:r')
        return WQ(filename .. ':' .. line('.'))
    endif

    return inner
enddef

def MakeString(inner: string, wrapIntoTrace: bool = false): string
    var result = 'console.' .. (wrapIntoTrace ? 'groupCollapsed' : 'log') .. '('
    for prefix in g:js_fastlog_prefix
        result = result .. WQ(prefix) .. ', '
    endfor
    result = result .. inner
    result = result .. ')'

    result = result .. (search(';') ? ';' : '')
    return result
enddef

export def JsFastLog(visualmode: string, logmode: number, wrapIntoTrace: bool = false): void
    if (visualmode ==# 'V' || visualmode ==# '')
        normal! O// js-fastlog: sorry, but I work only with charwise selection
        return
    endif

    var word = GetWord()

    var wordIsEmpty = match(word, '\v\S') == -1
    if (logmode !=# logModes.separator
         && logmode !=# logModes.lineNumber
         && wordIsEmpty)
        execute "normal! aconsole.log();\<esc>hh"
    else
        put = MakeString(MakeInner(logmode, word), wrapIntoTrace)

        if (logmode ==# logModes.funcTimestamp
            || logmode ==# logModes.separator)
            normal! ==f(l
        else
            :-delete _ | normal! ==f(l
        endif
    endif

    if (wrapIntoTrace)
        execute 'normal oconsole.trace()' .. (search(';') ? ';' : '')
        execute 'normal oconsole.groupEnd()' .. (search(';') ? ';' : '')
        normal kk
    endif

    # move cursor to end of line -2 columns
    normal! $hh
enddef

export def GetLogModes(): dict<number>
    return logModes
enddef
