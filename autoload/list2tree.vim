let s:save_cpo = &cpo
set cpo&vim

let s:INDENT_UNIT     = 2
let s:NON_RULE        = 0
let s:VERTICAL_RULE   = 1 "│
let s:CONTINUOUS_RULE = 2 "├──
let s:LAST_RULE       = 3 "└──

function! list2tree#make() range
  let s:firstline = a:firstline
  let s:lastline = a:lastline

  try
    let [l:parse_lines_list, l:depths] = list2tree#parse_lines()
  catch
    return
  endtry

  let l:tree = list2tree#make_tree(l:parse_lines_list, l:depths)

  for l:line_number in range(s:firstline, s:lastline)
    call setline(l:line_number, l:tree[l:line_number - s:firstline])
  endfor
endfunction


function! list2tree#parse_lines() abort
  let l:parse_lines_list = []
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
    if l:match_end % s:INDENT_UNIT != 0
      echo 'List2Tree: Indent error. Use ' . s:INDENT_UNIT . ' spaces indent.'
      return
    endif

    " calculate depth
    let l:depth = l:match_end / s:INDENT_UNIT - 1

    call add(l:parse_lines_list, [l:line_number, l:depth, l:line_text])
    call add(l:depths, l:depth)
  endfor

  return [l:parse_lines_list, l:depths]
endfunction


function! list2tree#make_tree(parse_lines_list, depths)
  let l:tree = []
  let l:rules_flag_list = list2tree#make_empty_list(max(a:depths))
  let l:previous_depth = 0

  for [l:absolute_line_number, l:depth, l:original_text] in a:parse_lines_list
    let l:text = ''
    let l:relative_line_number = l:absolute_line_number - s:firstline + 1

    " set previous depths rules
    if l:depth != l:previous_depth && l:previous_depth != 0
      if l:depth > l:previous_depth
        " fix previous depths rule
        if l:rules_flag_list[l:previous_depth - 1] == s:LAST_RULE
          let l:rules_flag_list[l:previous_depth - 1] = s:NON_RULE
        elseif l:rules_flag_list[l:previous_depth - 1] == s:CONTINUOUS_RULE
          let l:rules_flag_list[l:previous_depth - 1] = s:VERTICAL_RULE
        endif
      else
        for l:i in range(l:depth + 1, l:previous_depth)
          let l:rules_flag_list[l:i - 1] = s:NON_RULE
        endfor
      endif
    endif

    " set current rule
    if l:depth != 0
      if l:relative_line_number >= len(a:depths)
        let l:is_last_of_same_depth = 1
      else
        let l:is_last_of_same_depth = list2tree#is_last_of_same_depth(l:depth, a:depths[l:relative_line_number:])
      endif

      if l:is_last_of_same_depth
        let l:rules_flag_list[l:depth - 1] = s:LAST_RULE
      else
        let l:rules_flag_list[l:depth - 1] = s:CONTINUOUS_RULE
      endif
    endif

    " join rule strings
    let l:text .= list2tree#make_rule_strings(l:rules_flag_list)

    if l:depth != 0
      " rstrip
      let l:text = substitute(l:text, '^\(.\{-}\)\s*$', '\1', '') . ' '
    else
      " strip
      let l:text = substitute(l:text, '^\s*\(.\{-}\)\s*$', '\1', '')
    endif

    " join original_text
    let l:text .= l:original_text

    call add(l:tree, l:text)
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


function! list2tree#make_rule_strings(rules_flag_list)
  let l:text = ''

  for l:i in a:rules_flag_list
    if l:i == s:VERTICAL_RULE
      let l:text .= '│   '
    elseif l:i == s:CONTINUOUS_RULE
      let l:text .= '├── '
    elseif l:i == s:LAST_RULE
      let l:text .= '└── '
    else
      let l:text .= '    '
    endif
  endfor

  return l:text
endfunction


function! list2tree#is_last_of_same_depth(current_depth, after_depths)
  for l:i in a:after_depths
    if a:current_depth < l:i
      continue
    elseif a:current_depth == l:i
      return v:false
    else
      return v:true
    endif
  endfor

  return v:true
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
