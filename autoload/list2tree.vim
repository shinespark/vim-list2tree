let s:save_cpo = &cpo
set cpo&vim

function! list2tree#make() range
  " echo "firstline: " . a:firstline
  " echo "lastline: " . a:lastline

  let s:indent_unit = 2
  let s:rule = ['│', '─', '└', '├']

  let s:before_list_depth = 1
  let s:list = []
  let s:tree_str = []

  for s:line_number in range(a:firstline, a:lastline)
    echo " "

    let s:current_line = getline(s:line_number)
    echo s:line_number . ':' .'raw_line: ' . s:current_line

    let s:match_end = matchend(s:current_line, '^\ *\*\ ', 0)
    let s:line_str = s:current_line[s:match_end:]

    if s:match_end % s:indent_unit != 0
      echo 'List2Tree: Indent error.'
      return
    endif

    let s:list_depth = s:match_end / s:indent_unit
    echo "list_depth: " . s:list_depth
    call add(s:list, s:list_depth)
    call add(s:tree_str, repeat(' ', (s:list_depth - 1) * s:indent_unit) . s:line_str)
  endfor

  echo s:list
  echo s:tree_str
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
