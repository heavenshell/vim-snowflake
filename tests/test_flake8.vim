let s:save_cpo = &cpo
set cpo&vim

function! TestShouldShowQuickFix()
  :e ./fixtures/flake.py
  :Snowflake
  :sleep 1
  let qflist = getqflist()
  call assert_equal(len(qflist), 1)
  let qf = qflist[0]
endfunction

function! TestShouldRunCallback()
  function! s:callback(...)
    call assert_true(1)
  endfunction
  let g:snowflake_callbacks = {
    \ 'after_run': function('s:callback')
    \ }
  :e ./fixtures/flake.py
  :Snowflake
  :sleep 1
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
