let s:save_cpo = &cpo
set cpo&vim

function! list2tree#make() range
  " echo "firstline: " . a:firstline
  " echo "lastline: " . a:lastline

  let s:indent_unit = 2
  let s:rule = ['│', '─', '└', '├']

  let s:before_list_depth = 1
  let s:list = []
  let s:tree_list = []

  for s:line_number in range(a:firstline, a:lastline)
    echo " "

    let s:current_line = getline(s:line_number)
    echo s:line_number . ':' .'raw_line: ' . s:current_line

    " get '* '
    let s:match_end = matchend(s:current_line, '^\ *\*\ ', 0)
    let s:line_text = s:current_line[s:match_end:]

    if s:match_end % s:indent_unit != 0
      echo 'List2Tree: Indent error.'
      return
    endif

    " depthを計算
    let s:list_depth = s:match_end / s:indent_unit
    echo "list_depth: " . s:list_depth


    let s:tree_line = ''
    " 前の行よりネストしている場合
    if s:list_depth > s:before_list_depth
      let s:tree_line = repeat(' ', (s:list_depth - 1) * s:indent_unit) . s:tree_line . '└'
    endif


    " listに格納
    call add(s:list, s:list_depth)

    " 試しにfor文内で整形してみる
    " call add(s:tree_str, repeat('─', (s:list_depth - 1) * s:indent_unit) . s:line_text)
    if s:list_depth == 1
      call add(s:tree_list, s:line_text)
    else
      call add(s:tree_list, s:tree_line . '─' . s:line_text)
    endif

    let s:before_list_depth = s:list_depth
  endfor

  echo s:list

  for s:tree_line in s:tree_list
    echo s:tree_line
  endfor
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
