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


    " 一旦depthのみを考慮したlineを整形
    if s:list_depth == 1
      let s:tree_line = s:line_text
    else
      let s:tree_line = repeat('  ', (s:list_depth - 2) * s:indent_unit) . '├─' . s:line_text
    endif



    " listに格納
    call add(s:list, s:list_depth)
    call add(s:tree_list, [s:line_number, s:list_depth, s:tree_line])

    " depthが浅くなった際に、既存箇所の縦線の書き換えを行う
    echo " "
    if s:list_depth < s:before_list_depth

      echo "既存の書き換え"
      echo reverse(copy(s:tree_list[:s:line_number - 2]))

      for [s:temp_line_number, s:temp_list_depth, s:temp_tree_line] in reverse(copy(s:tree_list[:s:line_number - 2]))
        echo s:temp_list_depth . s:temp_tree_line

        " 置換対象文字列の取得
        let s:splitted_temp_tree_line = split(s:temp_tree_line, '\zs')

        echo s:splitted_temp_tree_line
        let s:splitted_temp_tree_line[s:list_depth - 2] = '│'
        let s:replaced_temp_tree_line = join(s:splitted_temp_tree_line, '')
        echo s:replaced_temp_tree_line

        " 書き換え
        let s:tree_list[s:temp_line_number - 1] = [s:temp_line_number, s:temp_list_depth, s:replaced_temp_tree_line]

        if s:list_depth == s:temp_list_depth
          break
        endif
      endfor

      echo "既存の書き換え終わり"

    endif

    if s:list_depth == s:before_list_depth
    endif

    " 試しにfor文内で整形してみる
    " call add(s:tree_str, repeat('─', (s:list_depth - 1) * s:indent_unit) . s:line_text)
    " if s:list_depth == 1
      " call add(s:tree_list, [s:list_depth, s:line_text])
    " else
      " call add(s:tree_list, [s:list_depth, s:tree_line . '─' . s:line_text])
    " endif

    let s:before_list_depth = s:list_depth
  endfor

  echo s:list

  for [s:line_number, s:list_depth, s:tree_line] in s:tree_list
    echo s:line_number . ": " . s:list_depth . ": " . s:tree_line
  endfor
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
