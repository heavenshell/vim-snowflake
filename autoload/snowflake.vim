" File: snowflake.vim
" Author: Shinya Ohyanagi <sohyanagi@gmail.com>
" WebPage:  http://github.com/heavenshell/vim-snowflake/
" Description: An asynchronous Python source code checker.
" License: BSD, see LICENSE for more details.
let s:save_cpo = &cpo
set cpo&vim

let g:snowflake_linters = get(g:, 'snowflake_linters', [
      \ 'flake8',
      \ ])
let g:snowflake_enable_quickfix = get(g:, 'snowflake_enable_quickfix', 0)
let g:snowflake_callbacks = get(g:, 'snowflake_callbacks', {})
let g:snowflake_ignore = ''
let s:linter = ''

function! snowflake#linter()
  return s:linter
endfunction

function! snowflake#detect_linter() abort
  if s:linter != ''
    return s:linter
  endif

  for lint in g:snowflake_linters
    if executable(lint) == 1
      let s:linter = lint
      break
    endif
  endfor

  return s:linter
endfunction

function! snowflake#init() abort
  if has_key(g:snowflake_callbacks, 'before_init')
    call g:snowflake_callbacks['before_init']()
  endif

  call snowflake#detect_linter()

  augroup snowflake
    autocmd!
    autocmd BufWritePost *.py call snowflake#flake8#run()
    autocmd InsertLeave *.py call snowflake#flake8#run()
    autocmd TextChanged,TextChangedI *.py call snowflake#flake8#run()
  augroup END

  if has_key(g:snowflake_callbacks, 'after_init')
    call g:snowflake_callbacks['after_init']()
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
