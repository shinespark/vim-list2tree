let s:save_cpo = &cpo
set cpo&vim

command! -range List2Tree <line1>,<line2>call list2tree#make()

let &cpo = s:save_cpo
unlet s:save_cpo
