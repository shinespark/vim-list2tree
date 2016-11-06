let s:save_cpo = &cpo
set cpo&vim

function! list2tree#make() range
  echo "firstline: " . a:firstline
  echo "lastline: " . a:lastline

  for line_number in range(a:firstline, a:lastline)
    let current_line = getline(line_number)
    echo current_line
  endfor
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
