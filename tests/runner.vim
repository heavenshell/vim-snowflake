let s:save_cpo = &cpo
set cpo&vim

function! s:parse_errors()
  let errors = []

  for e in v:errors
    let msg = split(e, '\.\.')[1]
    call add(errors, msg)
  endfor
  let v:errors = []

  return errors
endfunction

function! SnowflakeRunTest()
  let files = split(glob('test_*.vim'), "\n")
  let tests = []
  let test_cnt = 0
  for f in files
    " Open test file.
    execute 'so ' . f

    let lines = readfile(f)
    for line in lines
      if line =~ '^function! Test'
        let test_cnt = test_cnt + 1
        let name = substitute(line, 'function! ', '', '')
        call add(tests, {'file': f, 'name': name})
      endif
    endfor
  endfor

  let results = []
  let error_results = []
  for t in tests
    let v:errors = []
    execute ':call ' . t['name']
    let errors = s:parse_errors()
    call add(results, 'Test for ' . t['file'])
    let msg = ''
    if len(errors) > 0
      for e in errors
        let msg = '  [✖] ' . e
        call add(results, msg)
        call add(error_results, e)
      endfor
    else
      let msg = '  [✓] ' . t['name']
      call add(results, msg)
    endif
  endfor

  " let results = filter(copy(results), 'index(results, v:val, v:key + 1) == -1')

  let error_cnt = len(error_results)
  call add(results, '')
  let msg = printf('Sucess: %d Failures: %d Total: %d', (test_cnt - error_cnt), error_cnt, test_cnt)
  call add(results, msg)

  " Delete outputs if exists.
  if findfile('outputs', '.')
    call delete(outputs)
  endif
  call writefile(results, './outputs')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
