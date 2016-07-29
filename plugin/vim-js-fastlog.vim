let fastlog_empty = "normal! aconsole.log();\<esc>hh"

function! jsFastLog(superSmart)
    let word = ""
    if (visualmode() == 'v')
        let word = s:get_visual_selection()
    else
        let word = expand("<cword>")
    endif

    if empty(word)
            :execute fastlog_empty
    elseif(a:superSmart == 1)
            " lalka => console.log(`lalka=${JSON.stringify(lalka)}`);
            :execute "normal! viWdaconsole.log(`\<esc>pa=${JSON.stringify(\<esc>pa)}`);"
    elseif(a:superSmart == 2)
            " lalka => console.log(Date.now() % 10000 + 'lalka');
            let fname = expand('%:t:r')
            let command = "normal! viwyoconsole.log(Date.now() % 10000 + ` ".fname."::\<esc>pa`);"
            :execute command
    elseif(a:superSmart == 3)
            " lalka => console.log('lalka');
            :execute "normal! viWdaconsole.log(`\<esc>pa`);"
    elseif(a:superSmart == 4)
            " lalka => console.log('lalka=', lalka);
            :execute "normal! viWdaconsole.log('\<esc>pa=', \<esc>pa);"
        else
            " lalka => console.log(lalka);
            :execute "normal! viWdaconsole.log(\<esc>pa);"
    endif
endfunction
