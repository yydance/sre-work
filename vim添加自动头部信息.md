vim ~/.vimrc
```
"SET Comment START
autocmd BufNewFile *.sh,*.py,*.php,*.js,*.cpp exec ":call SetComment()" |normal 10Go
func SetComment()
    if expand("%:e") == 'php'
        call setline(1, "<?php")
    elseif expand("%:e") == 'js'
        call setline(1, '//JavaScript file')
    elseif expand("%:e") == 'cpp'
        call setline(1, '//C++ file')
    elseif expand("%:e") == 'sh'
        call setline(1,'#!/bin/bash -c')
    elseif expand("%:e") == 'py'
        call setline(1,'#!/usr/bin/env python')
    endif
    call append(1, '# ===============================================')
    call append(2, '# 文件名称: '.expand("%"))
    call append(3, '# 创 建 者: Damon - damonops@163.com')
    call append(4, '# 创建日期: '.strftime("%Y-%m-%d %H:%M:%S"))
    call append(5, '# 修改日期: '.strftime("%Y-%m-%d %H:%M:%S"))
    call append(6, '# 描    述: ---')
    call append(7, '# ===============================================')
"    call append(10, '')
endfunc
map <F2> :call SetComment()<CR>:10<CR>o
"SET Comment END
"SET Last Modified Time START
func DataInsert()
    call cursor(9,1)
    if search ('修改日期') != 0
    let line = line('.')
    call setline(line, '# 修改日期: '.strftime("%Y-%m-%d %H:%M:%S"))
    endif
endfunc
autocmd FileWritePre,BufWritePre *.sh,*.py,*.php,*.js,*.cpp ks|call DataInsert() |'s
"SET Last Modified Time END
```
