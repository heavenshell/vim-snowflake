" File: snowflake.vim
" Author: Shinya Ohyanagi <sohyanagi@gmail.com>
" WebPage:  http://github.com/heavenshell/vim-snowflake/
" Description: An asynchronous Python source code checker for Vim.
" License: BSD, see LICENSE for more details.
let s:save_cpo = &cpo
set cpo&vim

if get(b:, 'loaded_snowflake')
  finish
endif

" version check
if !has('channel') || !has('job')
  echoerr '+channel and +job are required for snowflake.vim'
  finish
endif

command! -buffer Snowflake :call snowflake#flake8#run()

noremap <silent> <buffer> <Plug>(Snowflake) :Snowflake <CR>

let g:snowflake_enable_init = get(g:, 'snowflake_enable_init', 1)
if g:snowflake_enable_init == 1
  call snowflake#init()
endif

let b:loaded_snowflake = 1

let &cpo = s:save_cpo
unlet s:save_cpo
