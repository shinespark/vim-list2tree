let s:save_cpo = &cpo
set cpo&vim

let s:indent_unit = 2

function! list2tree#make() range
  let s:firstline = a:firstline
  let s:lastline = a:lastline
  echo s:firstline
  echo s:lastline

  " 各lineのdepthを取得
  try
    let [l:depths_texts, l:depths] = list2tree#get_lines_depths()
    echo l:depths_texts
  catch
    return
  endtry

  " 各line depthに応じたruleを生成
  let l:tree = list2tree#make_tree(l:depths_texts, l:depths)

  " 各lineを置換する
  for l:line_number in range(s:firstline, s:lastline)
    call setline(l:line_number, l:tree[l:line_number - s:firstline])
  endfor
endfunction


" 各lineのdepthを取得
function! list2tree#get_lines_depths() abort
  let l:depths_texts = []
  let l:depths = []

  for l:line_number in range(s:firstline, s:lastline)
    let l:raw_line_text = getline(l:line_number)

    " get '* '
    let l:match_end = matchend(l:raw_line_text, '^\ *\*\ ', 0)
    if l:match_end == -1
      echo 'List2Tree: Syntax error. Could''t find  *.'
      return
    endif

    let l:line_text = l:raw_line_text[l:match_end:]
    if l:match_end % s:indent_unit != 0
      echo 'List2Tree: Indent error. Use ' . s:indent_unit . ' spaces indent.'
      return
    endif

    " depthを計算
    let l:depth = l:match_end / s:indent_unit - 1
    echo l:line_number . "  depth: " . l:depth . " line_text: " . l:line_text

    call add(l:depths_texts, [l:line_number, l:depth, l:line_text])
    call add(l:depths, l:depth)
  endfor

  return [l:depths_texts, l:depths]
endfunction


" 各line depthに応じたruleを生成
function! list2tree#make_tree(depths_texts, depths)
  " depthごとにruleを
  let l:tree = []
  let l:rules_flag_list = list2tree#make_empty_list(max(a:depths))
  let l:previous_depth = 0

  " LINEづくり
  for [l:number, l:depth, l:text] in a:depths_texts
    let l:number = l:number - s:firstline + 1
    echo l:number
    let l:line = ''

    " 前回とdepthが変わっていたら前回のdepthを処理する
    if l:depth != l:previous_depth && l:previous_depth != 0
      " 1個前の階層のフラグを1に
      if l:depth > l:previous_depth
        if l:rules_flag_list[l:previous_depth - 1] == 3
          let l:rules_flag_list[l:previous_depth - 1] = 0
        elseif l:rules_flag_list[l:previous_depth - 1] == 2
          let l:rules_flag_list[l:previous_depth - 1] = 1
        endif
      else
        for l:i in range(l:depth + 1, l:previous_depth)
          let l:rules_flag_list[l:i - 1] = 0
        endfor
      endif
    endif

    " 一階層目以外は、'└' or '├' 判定
    if l:depth != 0
      if l:number >= len(a:depths)
        let l:is_last_depth = 1
      else
        let l:is_last_depth = list2tree#is_last_depth(l:depth, a:depths[l:number:])
      endif

      if l:is_last_depth
        let l:rules_flag_list[l:depth - 1] = 3
      else
        let l:rules_flag_list[l:depth - 1] = 2
      endif
    endif

    echo l:rules_flag_list

    let l:line .= list2tree#get_rule_text(l:rules_flag_list)

    " rstrip()
    let l:line = substitute(l:line, '^\(.\{-}\)\s*$', '\1', '')
    " join text
    let l:line .= ' ' . l:text

    call add(l:tree, l:line)
    let l:previous_depth = l:depth
  endfor

  return l:tree
endfunction


function! list2tree#make_empty_list(length)
  let l:list = []

  for l:i in range(a:length)
    call add(l:list, 0)
  endfor

  return l:list
endfunction


function! list2tree#get_rule_text(rules_flag_list)
  let l:text = ''

  for l:i in a:rules_flag_list
    if l:i == 1
      let l:text .= '│   '
    elseif l:i == 2
      let l:text .= '├─ '
    elseif l:i == 3
      let l:text .= '└─ '
    else
      let l:text .= '     '
    endif
  endfor

  return l:text
endfunction


" 最終行かどうか確認する
function! list2tree#is_last_depth(current_depth, depths)
  for l:i in a:depths
    if a:current_depth < l:i
      continue
    elseif a:current_depth == l:i
      return 0
    else
      return 1
    endif
  endfor
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
