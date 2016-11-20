let s:save_cpo = &cpo
set cpo&vim

let s:tree = []
let s:before_text = ''
let s:previous_depth = 1
let s:indent_unit = 2
let s:rule = ['│', '─', '└', '├']

function! list2tree#make() range
  echo a:firstline
  echo a:lastline
  let s:firstline = a:firstline
  let s:lastline = a:lastline
  echo s:firstline
  echo s:lastline

  " 各lineのdepthを取得
  " call list2tree#get_lines_depths()
  let [l:depths_texts, l:max_depth] = list2tree#get_lines_depths()
  " echo l:depths_texts

  " 各line depthに応じたruleを生成
  let l:tree = list2tree#make_line_rules(l:depths_texts, l:max_depth)
  echo l:tree
endfunction


" 各lineのdepthを取得
function! list2tree#get_lines_depths()
  echo s:firstline
  echo s:lastline
  " 各lineの深さ
  let l:depths_texts = []
  let l:texts = []
  let l:depths = []

  for l:line_number in range(s:firstline, s:lastline)
    let l:raw_line_text = getline(l:line_number)

    " get '* '
    let l:match_end = matchend(l:raw_line_text, '^\ *\*\ ', 0)
    let l:line_text = l:raw_line_text[l:match_end:]

    if l:match_end % s:indent_unit != 0
      echo 'List2Tree: Indent error.'
      return
    endif

    " depthを計算
    let l:depth = l:match_end / s:indent_unit - 1
    echo l:line_number . "  depth: " . l:depth . " line_text: " . l:line_text

    call add(l:depths_texts, [l:line_number, l:depth, l:line_text])
    call add(l:depths, l:depth)
    call add(l:texts, l:line_text)
  endfor

  " return [l:lines, l:depths]
  return [l:depths_texts, max(l:depths)]
endfunction


" 各line depthに応じたruleを生成
function! list2tree#make_line_rules(depths_texts, max_depth)
  " depthごとにruleを
  let l:tree = []
  let l:rules_flag_list = list2tree#make_empty_list(a:max_depth)
  let l:previous_depth = 0

  " LINEづくり
  for [l:number, l:depth, l:text] in a:depths_texts
    let l:line = ''

    " depthに応じてflagを追加
    if l:depth > l:previous_depth
      " 1個前の階層のフラグを1に
      let l:rules_flag_list[l:previous_depth] = 1

      " 次のlineのdepthをチェック(l:number = 次の行のインデックス)
      let l:next_depth = get(a:depths_texts[1], l:number)

      if l:depth == l:next_depth
        let l:rules_flag_list[l:depth - 1] = 2
      elseif l:depth > l:next_depth
        let l:rules_flag_list[l:depth - 1] = 2
      else
        let l:rules_flag_list[l:depth - 1] = 3
      endif
    elseif l:depth < l:previous_depth
      echo "elseif"
      for l:i in range(l:depth, l:previous_depth - 1)
        echo l:i
        let l:rules_flag_list[l:i - 1] = 1
      endfor
    endif


    let l:line .= list2tree#get_rule_text(l:rules_flag_list)

    " ここから罫線処理
    " まず同階層の最後かチェック
    " if list2tree#is_last_of_same_depth(l:number, l:depth)
    " endif

    let l:line .= l:text
    echo l:rules_flag_list
    echo l:line

    call add(l:tree, l:line)
    let l:previous_depth = l:depth
  endfor

  return l:tree
endfunction


function! list2tree#make_empty_list(length)
  let l:list = []

  for i in range(a:length)
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
      " let l:text .= '     '
    endif
  endfor

  return l:text
endfunction


function! list2tree#is_last_of_same_depth(raw_line_text)
  echo 'raw_line: ' . a:raw_line_text
endfunction


function! list2tree#add_tree(raw_line_text)
  echo 'raw_line: ' . a:raw_line_text
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
