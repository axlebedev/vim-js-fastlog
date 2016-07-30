let fastlog_empty = "normal! aconsole.log();\<esc>hh"

function! JsFastLog(superSmart)
    let saved_isk = &iskeyword
    execute "set iskeyword+=."

    let word = ""
    if (visualmode() == 'v')
        let word = l9#getSelectedText()
    else
        let word = expand("<cword>")
    endif

    if empty(word)
        :execute fastlog_empty
    elseif(a:superSmart == 1)
        " somevar => console.log(`somevar=${JSON.stringify(somevar)}`);
        :execute "put ='console.log(`".word."=${JSON.stringify(".word.")}`);'"
        :execute "-delete | normal! =="
    elseif(a:superSmart == 2)
        " somevar => console.log(Date.now() % 10000 + 'somevar');
        let filename = expand('%:t:r')
        :execute "put ='console.log(Date.now() % 10000 + ` ".filename."::".word."`);'"
        :execute "normal! =="
    elseif(a:superSmart == 3)
        " somevar => console.log('somevar');
        :execute "put ='console.log(''".word."'');'"
        :execute "-delete | normal! =="
    elseif(a:superSmart == 4)
        " somevar => console.log('somevar=', somevar);
        :execute "put ='console.log(''".word."='', ".word.");'"
        :execute "-delete | normal! =="
    else
        " somevar => console.log(somevar);
        :execute "put ='console.log(".word.");'"
        :execute "-delete | normal! =="
    endif


    let &iskeyword = saved_isk 
endfunction
