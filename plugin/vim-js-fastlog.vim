function! JsFastLog(superSmart)
    let saved_isk = &iskeyword
    execute "set iskeyword+=."

    let word = ""
    if (visualmode() == 'v')
        let word = l9#getSelectedText()
    else
        let word = expand("<cword>")
    endif
    echom 'JsFastLog: word = '.word

    if empty(word)
        :execute "normal! aconsole.log();\<esc>hh"
    elseif(a:superSmart == 1)
        " somevar => console.log(`somevar=${JSON.stringify(somevar)}`);
        :execute "put ='console.log(`".word."=${JSON.stringify(".word.")}`);'"
        :execute '-delete _ | normal! =='
    elseif(a:superSmart == 2)
        " somevar => console.log(Date.now() % 10000 + 'somevar');
        let filename = expand('%:t:r')
        echom "put ='console.log(Date.now() % 10000 + ` "
        :execute "put ='console.log(Date.now() % 10000 + ` ".filename."::".word."`);'"
        :execute "normal! =="
    elseif(a:superSmart == 3)
        " somevar => console.log('somevar');
        :execute "put ='console.log(''".word."'');'"
        :execute "-delete _ | normal! =="
    elseif(a:superSmart == 4)
        " somevar => console.log('somevar=', somevar);
        :execute "put ='console.log(''".word."='', ".word.");'"
        :execute "-delete _ | normal! =="
    else
        " somevar => console.log(somevar);
        :execute "put ='console.log(".word.");'"
        :execute "-delete _ | normal! =="
    endif

    let &iskeyword = saved_isk 
endfunction


function! JsFastLog_stringify()
    :call JsFastLog(1)
endfunction

function! JsFastLog_function()
    :call JsFastLog(2)
endfunction

function! JsFastLog_string()
    :call JsFastLog(3)
endfunction

function! JsFastLog_dir()
    :call JsFastLog(4)
endfunction
