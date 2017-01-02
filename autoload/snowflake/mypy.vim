let s:save_cpo = &cpo
set cpo&vim

let s:mypy_executable = 0
if executable(g:snowflake_mypy)
  let s:mypy_executable = 1
endif

function! s:parse(msg)
  let outputs = []
  if a:msg =~ 'note' || a:msg =~ "mypy: can't read file"
    return outputs
  endif
  echomsg a:msg

  let results = split(a:msg, ':')
  if len(results) != 5
    return outputs
  endif
  let code = results[3]
  let level = 'E'

  if code !~ 'error'
    let level = 'W'
  endif

  call add(outputs, {
        \ 'filename': results[0],
        \ 'lnum': results[1],
        \ 'col': str2nr(results[2]) + 1,
        \ 'text': '[Mypy]' . results[4],
        \ 'type': level
        \})

  return outputs
endfunction

function! s:callback(ch, msg)
  " Ignore `note` message.
  let outputs = s:parse(a:msg)
  if len(outputs) == 0
    return
  endif

  if len(outputs) == 0 && len(getqflist()) == 0
    " No Errors. Clear quickfix then close window if exists.
    call setqflist([], 'r')
    cclose
  else
    call setqflist(outputs, 'a')
    if g:snowflake_enable_quickfix == 1
      cwindow
    endif
  endif
endfunction

function! s:exit_callback(c, msg) abort
  " No errors.
  if has_key(g:snowflake_callbacks, 'after_run')
    call g:snowflake_callbacks['after_run'](a:c, a:msg)
  endif
endfunction

function! snowflake#mypy#run() abort
  if has_key(g:snowflake_callbacks, 'before_run')
    call g:snowflake_callbacks['before_run']()
  endif
  if s:mypy_executable == 0
    return
  endif
  if exists('s:job') && job_status(s:job) != 'stop'
    call job_stop(s:job)
  endif

  let file = expand('%:p')
  " mypy --shadow-file is insteadof stdin.
  " Write current buffer to temp file and send to mypy.
  let lines = getline(1, '$')
  let tmp = tempname()
  call writefile(lines, tmp)

  " TODO --silent-imports will be deprecated since mypy 0.4.7
  let cmd = printf('mypy --incremental --silent-imports --show-column-numbers --shadow-file %s %s %s', file, tmp, file)
  "let cmd = printf('mypy --incremental --show-column-numbers %s', file)
  if g:snowflake_mypy_fast_parser == 1
    let cmd = cmd . ' --fast-parser'
  endif

  let s:job = job_start(cmd, {
        \ 'callback': {c, m -> s:callback(c, m)},
        \ 'exit_cb': {c, m -> s:exit_callback(c, m)},
        \ 'in_io': 'buffer',
        \ 'in_name': file,
        \ })
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
