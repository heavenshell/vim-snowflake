let s:save_cpo = &cpo
set cpo&vim

function! TestDefaultLinterShouldBeFlake8()
  call snowflake#detect_linter()
  let linter = snowflake#linter()
  call assert_equal(linter, 'flake8')
endfunction

function! TestLinterSetByUser()
  let g:snowflake_linters = ['pyflakes']
  call snowflake#detect_linter()
  let linter = snowflake#linter()
  call assert_equal(linter, 'pyflakes')
endfunction

function! TestInitCallbackShouldRun()
  function! s:callback()
    call assert_true(1)
  endfunction

  let g:snowflake_callbacks = {
    \ 'before_init': function('s:callback'),
    \ 'after_init': function('s:callback')
    \ }
  call snowflake#init()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
