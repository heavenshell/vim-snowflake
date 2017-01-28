" File: snowflake#flake8.vim
" Author: Shinya Ohyanagi <sohyanagi@gmail.com>
" WebPage:  http://github.com/heavenshell/vim-snowflake/
" Description: Check Python source code by Flake8.
" License: BSD, see LICENSE for more details.
let s:save_cpo = &cpo
set cpo&vim

let s:format = '%(path)s|%(row)d|%(col)d|%(code)s|%(text)s'

function! s:parse(msg)
  let outputs = []
  if a:msg !~ '|'
    return outputs
  endif

  let results = split(a:msg, '|')

  " TODO Error code.
  let level = 'E'
  let code = results[3]
  if code =~ 'E'     " PEP8 runtime errors
    if code == 'E901' || code == 'E902' || code == 'E999'
      let level = 'E'
    else
      let level = 'W'
    endif
  elseif code =~ 'F' " Flake8 runtime errors
    let level = 'E'
  elseif code =~ 'W' " PEP8 errors & warings
    let level = 'W'
  elseif code =~ 'D' " Naming (PEP8) & docstring (PEP257) conventions
    let level = 'W'
  endif

  call add(outputs, {
        \ 'filename': results[0],
        \ 'lnum': results[1],
        \ 'col': results[2],
        \ 'text': '[Flake8]' . ' ' . code . ' ' . results[4],
        \ 'type': level
        \})

  return outputs
endfunction

function! s:callback(ch, msg)
  let outputs = s:parse(a:msg)

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

function! snowflake#flake8#run() abort
  if has_key(g:snowflake_callbacks, 'before_run')
    call g:snowflake_callbacks['before_run']()
  endif
  if exists('s:job') && job_status(s:job) != 'stop'
    call job_stop(s:job)
  endif

  call setqflist([], 'r')
  let file = expand('%:p')
  let linter = snowflake#linter()
  if linter == ''
    return
  endif
  let cmd = printf('%s --format %s --stdin-display-name=%s', linter, s:format, file)
  if g:snowflake_ignore != ''
    let cmd = cmd . printf(' --ignore %s', g:snowflake_ignore)
  endif

  let bufnum = bufnr('%')
  let input = join(getbufline(bufnum, 1, '$'), "\n") . "\n"

  " Read from stdin.
  let cmd = cmd . ' -'

  " let s:job = job_start(cmd, {
  "       \ 'callback': {c, m -> s:callback(c, m)},
  "       \ 'exit_cb': {c, m -> s:exit_callback(c, m)},
  "       \ 'in_io': 'buffer',
  "       \ 'in_name': file,
  "       \ 'timeout': 10000,
  "       \ })

  let s:job = job_start(cmd, {
        \ 'callback': {c, m -> s:callback(c, m)},
        \ 'exit_cb': {c, m -> s:exit_callback(c, m)},
        \ 'in_mode': 'nl',
        \ })
  " https://github.com/w0rp/ale/issues/39
  " https://github.com/macvim-dev/macvim/issues/402
  " MacVim throws an exception `E631: write_buf_line()` when buffer is
  " getting larger.
  " So, read buffer manually and send to channel.
  " This hack is w0rp's ale
  " https://github.com/w0rp/ale/blob/3083d05afd3818e5db33f066392935bbf828e263/plugin/ale/zmain.vim#L277-L284
  let channel = job_getchannel(s:job)
  if ch_status(channel) ==# 'open'
    call ch_sendraw(channel, input)
    call ch_close_in(channel)
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
