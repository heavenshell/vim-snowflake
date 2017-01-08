" File: snowflake.vim
" Author: Shinya Ohyanagi <sohyanagi@gmail.com>
" WebPage:  http://github.com/heavenshell/vim-snowflake/
" Description: An asynchronous Python source code checker for Vim.
" License: BSD, see LICENSE for more details.
let s:save_cpo = &cpo
set cpo&vim

let g:snowflake_linters = get(g:, 'snowflake_linters', [
      \ 'flake8',
      \ ])
let g:snowflake_enable_quickfix = get(g:, 'snowflake_enable_quickfix', 0)
let g:snowflake_callbacks = get(g:, 'snowflake_callbacks', {})
let g:snowflake_ignore = ''
let g:snowflake_mypy_bin = get(g:, 'snowflake_mypy_bin', 'mypy')
let g:snowflake_mypy_options = get(g:, 'snowflake_mypy_options', '')
let g:snowfalek_mypy_cache_dir = get(g:, 'snowflake_mypy_cache_dir', '')
let s:linter = ''

function! snowflake#linter()
  if s:linter != ''
    return s:linter
  endif

  return snowflake#detect_linter()
endfunction

function! snowflake#detect_linter() abort
  for lint in g:snowflake_linters
    if executable(lint) == 1
      let s:linter = lint
      break
    endif
  endfor

  return s:linter
endfunction

" Run flake8 and mypy at once.
function! snowflake#run() abort
  call setqflist([], 'r')
  call snowflake#flake8#run()
  call snowflake#mypy#run()
endfunction

function! snowflake#init() abort
  if has_key(g:snowflake_callbacks, 'before_init')
    call g:snowflake_callbacks['before_init']()
  endif

  call snowflake#detect_linter()

  if has_key(g:snowflake_callbacks, 'after_init')
    call g:snowflake_callbacks['after_init']()
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
