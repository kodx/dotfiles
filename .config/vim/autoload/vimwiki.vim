" vim:tabstop=2:shiftwidth=2:expandtab:foldmethod=marker:textwidth=79
" Vimwiki autoload plugin file
" Author: Maxim Kim <habamax@gmail.com>
" Home: http://code.google.com/p/vimwiki/

if exists("g:loaded_vimwiki_auto") || &cp
  finish
endif
let g:loaded_vimwiki_auto = 1

if has("win32")
  let s:os_sep = '\'
else
  let s:os_sep = '/'
endif

let s:badsymbols = '['.g:vimwiki_badsyms.g:vimwiki_stripsym.'<>|?*:"]'

" MISC helper functions {{{

function! vimwiki#chomp_slash(str) "{{{
  return substitute(a:str, '[/\\]\+$', '', '')
endfunction "}}}

function! vimwiki#mkdir(path) "{{{
  let path = expand(a:path)
  if !isdirectory(path) && exists("*mkdir")
    let path = vimwiki#chomp_slash(path)
    if s:is_windows() && !empty(g:vimwiki_w32_dir_enc)
      let path = iconv(path, &enc, g:vimwiki_w32_dir_enc)
    endif
    call mkdir(path, "p")
  endif
endfunction
" }}}

function! vimwiki#safe_link(string) "{{{
  return substitute(a:string, s:badsymbols, g:vimwiki_stripsym, 'g')
endfunction
"}}}

function! vimwiki#unsafe_link(string) "{{{
  return substitute(a:string, g:vimwiki_stripsym, s:badsymbols, 'g')
endfunction
"}}}

function! vimwiki#subdir(path, filename)"{{{
  let path = expand(a:path)
  let filename = expand(a:filename)
  let idx = 0
  while path[idx] ==? filename[idx]
    let idx = idx + 1
  endwhile

  let p = split(strpart(filename, idx), '[/\\]')
  let res = join(p[:-2], s:os_sep)
  if len(res) > 0
    let res = res.s:os_sep
  endif
  return res
endfunction"}}}

function! vimwiki#current_subdir()"{{{
  return vimwiki#subdir(VimwikiGet('path'), expand('%:p'))
endfunction"}}}

function! vimwiki#open_link(cmd, link, ...) "{{{
  if s:is_link_to_non_wiki_file(a:link)
    call s:edit_file(a:cmd, a:link)
  else
    if a:0
      let vimwiki_prev_link = [a:1, []]
    elseif &ft == 'vimwiki'
      let vimwiki_prev_link = [expand('%:p'), getpos('.')]
    endif

    if vimwiki#is_link_to_dir(a:link)
      if g:vimwiki_dir_link == ''
        call s:edit_file(a:cmd, VimwikiGet('path').a:link)
      else
        call s:edit_file(a:cmd, 
              \ VimwikiGet('path').a:link.
              \ g:vimwiki_dir_link.
              \ VimwikiGet('ext'))
      endif
    else
      call s:edit_file(a:cmd, VimwikiGet('path').a:link.VimwikiGet('ext'))
    endif
    
    if exists('vimwiki_prev_link')
      let b:vimwiki_prev_link = vimwiki_prev_link
    endif
  endif
endfunction
" }}}

function! vimwiki#select(wnum)"{{{
  if a:wnum < 1 || a:wnum > len(g:vimwiki_list)
    return
  endif
  if &ft == 'vimwiki'
    let b:vimwiki_idx = g:vimwiki_current_idx
  endif
  let g:vimwiki_current_idx = a:wnum - 1
endfunction
" }}}

function! vimwiki#generate_links()"{{{
  let links = s:get_links('*'.VimwikiGet('ext'))

  " We don't want link to itself.
  let cur_link = expand('%:t:r')
  call filter(links, 'v:val != cur_link')

  if len(links)
    call append(line('$'), '= Generated Links =')
  endif

  call sort(links)

  for link in links
    if s:is_wiki_word(link)
      call append(line('$'), '- '.link)
    else
      call append(line('$'), '- [['.link.']]')
    endif
  endfor
endfunction " }}}

function! s:is_windows() "{{{
  return has("win32") || has("win64") || has("win95") || has("win16")
endfunction "}}}

function! s:get_links(pat) "{{{
  " search all wiki files in 'path' and its subdirs.
  let subdir = vimwiki#current_subdir()
  let globlinks = glob(VimwikiGet('path').subdir.'**/'.a:pat)

  " remove .wiki extensions
  let globlinks = substitute(globlinks, '\'.VimwikiGet('ext'), "", "g")
  let links = split(globlinks, '\n')

  " remove backup files (.wiki~)
  call filter(links, 'v:val !~ ''.*\~$''')

  " remove paths
  let rem_path = escape(expand(VimwikiGet('path')).subdir, '\')
  call map(links, 'substitute(v:val, rem_path, "", "g")')

  " Remove trailing slashes.
  call map(links, 'substitute(v:val, "[/\\\\]*$", "", "g")')

  return links
endfunction "}}}

" Builtin cursor doesn't work right with unicode characters.
function! s:cursor(lnum, cnum) "{{{
    exe a:lnum
    exe 'normal! 0'.a:cnum.'|'
endfunction "}}}

function! s:filename(link) "{{{
  let result = vimwiki#safe_link(a:link)
  if a:link =~ '|'
    let result = vimwiki#safe_link(split(a:link, '|')[0])
  elseif a:link =~ ']['
    let result = vimwiki#safe_link(split(a:link, '][')[0])
  endif
  return result
endfunction
" }}}

function! s:is_wiki_word(str) "{{{
  if a:str =~ g:vimwiki_rxWikiWord && a:str !~ '[[:space:]\\/]'
    return 1
  endif
  return 0
endfunction
" }}}

function! s:edit_file(command, filename) "{{{
  let fname = escape(a:filename, '% ')
  call vimwiki#mkdir(fnamemodify(a:filename, ":p:h"))
  execute a:command.' '.fname
endfunction
" }}}

function! s:search_word(wikiRx, cmd) "{{{
  let match_line = search(a:wikiRx, 's'.a:cmd)
  if match_line == 0
    echomsg "vimwiki: Wiki link not found."
  endif
endfunction
" }}}

function! s:get_word_at_cursor(wikiRX) "{{{
  let col = col('.') - 1
  let line = getline('.')
  let ebeg = -1
  let cont = match(line, a:wikiRX, 0)
  while (ebeg >= 0 || (0 <= cont) && (cont <= col))
    let contn = matchend(line, a:wikiRX, cont)
    if (cont <= col) && (col < contn)
      let ebeg = match(line, a:wikiRX, cont)
      let elen = contn - ebeg
      break
    else
      let cont = match(line, a:wikiRX, contn)
    endif
  endwh
  if ebeg >= 0
    return strpart(line, ebeg, elen)
  else
    return ""
  endif
endf "}}}

function! s:strip_word(word) "{{{
  let result = a:word
  if strpart(a:word, 0, 2) == "[["
    " get rid of [[ and ]]
    let w = strpart(a:word, 2, strlen(a:word)-4)

    if w =~ '|'
      " we want "link" from [[link|link desc]]
      let w = split(w, "|")[0]
    elseif w =~ ']['
      " we want "link" from [[link][link desc]]
      let w = split(w, "][")[0]
    endif

    let result = vimwiki#safe_link(w)
  endif
  return result
endfunction
" }}}

function! s:is_link_to_non_wiki_file(link) "{{{
  " Check if link is to a non-wiki file.
  " The easiest way is to check if it has extension like .txt or .html
  if a:link =~ '\.\w\{1,4}$'
    return 1
  endif
  return 0
endfunction
" }}}

function! vimwiki#is_link_to_dir(link) "{{{
  " Check if link is to a directory.
  " It should be ended with \ or /.
  if a:link =~ '.\+[/\\]$'
    return 1
  endif
  return 0
endfunction
" }}}

function! s:print_wiki_list() "{{{
  let idx = 0
  while idx < len(g:vimwiki_list)
    if idx == g:vimwiki_current_idx
      let sep = ' * '
      echohl PmenuSel
    else
      let sep = '   '
      echohl None
    endif
    echo (idx + 1).sep.VimwikiGet('path', idx)
    let idx += 1
  endwhile
  echohl None
endfunction
" }}}

function! s:update_wiki_link(fname, old, new) " {{{
  echo "Updating links in ".a:fname
  let has_updates = 0
  let dest = []
  for line in readfile(a:fname)
    if !has_updates && match(line, a:old) != -1
      let has_updates = 1
    endif
    call add(dest, substitute(line, a:old, escape(a:new, "&"), "g"))
  endfor
  " add exception handling...
  if has_updates
    call rename(a:fname, a:fname.'#vimwiki_upd#')
    call writefile(dest, a:fname)
    call delete(a:fname.'#vimwiki_upd#')
  endif
endfunction
" }}}

function! s:update_wiki_links_dir(dir, old_fname, new_fname) " {{{
  let old_fname = substitute(a:old_fname, '[/\\]', '[/\\\\]', 'g')
  let new_fname = a:new_fname

  if !s:is_wiki_word(new_fname)
    let new_fname = '[['.new_fname.']]'
  endif
  if !s:is_wiki_word(old_fname)
    let old_fname = '\[\['.vimwiki#unsafe_link(old_fname).
          \ '\%(|.*\)\?\%(\]\[.*\)\?\]\]'
  else
    let old_fname = '\<'.old_fname.'\>'
  endif
  let files = split(glob(VimwikiGet('path').a:dir.'*'.VimwikiGet('ext')), '\n')
  for fname in files
    call s:update_wiki_link(fname, old_fname, new_fname)
  endfor
endfunction
" }}}

function! s:tail_name(fname) "{{{
  let result = substitute(a:fname, ":", "__colon__", "g")
  let result = fnamemodify(result, ":t:r")
  let result = substitute(result, "__colon__", ":", "g")
  return result
endfunction "}}}

function! s:update_wiki_links(old_fname, new_fname) " {{{
  let old_fname = s:tail_name(a:old_fname)
  let new_fname = s:tail_name(a:new_fname)

  let subdirs = split(a:old_fname, '[/\\]')[: -2]

  " TODO: Use Dictionary here...
  let dirs_keys = ['']
  let dirs_vals = ['']
  if len(subdirs) > 0
    let dirs_keys = ['']
    let dirs_vals = [join(subdirs, '/').'/']
    let idx = 0
    while idx < len(subdirs) - 1
      call add(dirs_keys, join(subdirs[: idx], '/').'/')
      call add(dirs_vals, join(subdirs[idx+1 :], '/').'/')
      let idx = idx + 1
    endwhile
    call add(dirs_keys,join(subdirs, '/').'/')
    call add(dirs_vals, '')
  endif

  let idx = 0
  while idx < len(dirs_keys)
    let dir = dirs_keys[idx]
    let new_dir = dirs_vals[idx]
    call s:update_wiki_links_dir(dir, 
          \ new_dir.old_fname, new_dir.new_fname)
    let idx = idx + 1
  endwhile
endfunction
" }}}

function! s:get_wiki_buffers() "{{{
  let blist = []
  let bcount = 1
  while bcount<=bufnr("$")
    if bufexists(bcount)
      let bname = fnamemodify(bufname(bcount), ":p")
      if bname =~ VimwikiGet('ext')."$"
        let bitem = [bname, getbufvar(bname, "vimwiki_prev_link")]
        call add(blist, bitem)
      endif
    endif
    let bcount = bcount + 1
  endwhile
  return blist
endfunction
" }}}

function! s:open_wiki_buffer(item) "{{{
  call s:edit_file('e', a:item[0])
  if !empty(a:item[1])
    call setbufvar(a:item[0], "vimwiki_prev_link", a:item[1])
  endif
endfunction
" }}}

" }}}

" SYNTAX highlight {{{
function! vimwiki#WikiHighlightLinks() "{{{
  let links = s:get_links('*'.VimwikiGet('ext'))

  " Links with subdirs should be highlighted for linux and windows separators
  " Change \ or / to [/\\]
  let os_p = '[/\\]'
  let os_p2 = escape(os_p, '\')
  call map(links, 'substitute(v:val, os_p, os_p2, "g")')

  for link in links
    if g:vimwiki_camel_case && 
          \ link =~ g:vimwiki_rxWikiWord && !s:is_link_to_non_wiki_file(link)
      execute 'syntax match VimwikiLink /!\@<!\<'.link.'\>/'
    endif
    execute 'syntax match VimwikiLink /\[\[\<'.
          \ vimwiki#unsafe_link(link).
          \ '\>\%(|\+.*\)*\]\]/'
    execute 'syntax match VimwikiLink /\[\[\<'.
          \ vimwiki#unsafe_link(link).
          \ '\>\]\[.\+\]\]/'
  endfor
  execute 'syntax match VimwikiLink /\[\[.\+\.\%(jpg\|png\|gif\)\%(|\+.*\)*\]\]/'
  execute 'syntax match VimwikiLink /\[\[.\+\.\%(jpg\|png\|gif\)\]\[.\+\]\]/'

  " highlight dirs
  let dirs = s:get_links('*/')
  call map(dirs, 'substitute(v:val, os_p, os_p2, "g")')
  for dir in dirs
    execute 'syntax match VimwikiLink /\[\[\<'.
          \ vimwiki#unsafe_link(dir).
          \ '\>[/\\]*\%(|\+.*\)*\]\]/'
  endfor
endfunction
" }}}

function! vimwiki#hl_exists(hl)"{{{
  if !hlexists(a:hl)
    return 0
  endif
  redir => hlstatus
  exe "silent hi" a:hl
  redir END
  return (hlstatus !~ "cleared")
endfunction
"}}}

function! vimwiki#nested_syntax(filetype, start, end, textSnipHl) abort "{{{
" From http://vim.wikia.com/wiki/VimTip857
  let ft=toupper(a:filetype)
  let group='textGroup'.ft
  if exists('b:current_syntax')
    let s:current_syntax=b:current_syntax
    " Remove current syntax definition, as some syntax files (e.g. cpp.vim)
    " do nothing if b:current_syntax is defined.
    unlet b:current_syntax
  endif

  " Some syntax files set up iskeyword which might scratch vimwiki a bit.
  " Let us save and restore it later.
  " let b:skip_set_iskeyword = 1
  let is_keyword = &iskeyword

  execute 'syntax include @'.group.' syntax/'.a:filetype.'.vim'
  try
    execute 'syntax include @'.group.' after/syntax/'.a:filetype.'.vim'
  catch
  endtry

  let &iskeyword = is_keyword

  if exists('s:current_syntax')
    let b:current_syntax=s:current_syntax
  else
    unlet b:current_syntax
  endif
  execute 'syntax region textSnip'.ft.'
        \ matchgroup='.a:textSnipHl.'
        \ start="'.a:start.'" end="'.a:end.'"
        \ contains=@'.group
endfunction "}}}

"}}}

" WIKI functions {{{
function! vimwiki#WikiNextWord() "{{{
  call s:search_word(g:vimwiki_rxWikiLink.'\|'.g:vimwiki_rxWeblink, '')
endfunction
" }}}

function! vimwiki#WikiPrevWord() "{{{
  call s:search_word(g:vimwiki_rxWikiLink.'\|'.g:vimwiki_rxWeblink, 'b')
endfunction
" }}}

function! vimwiki#WikiFollowWord(split) "{{{
  if a:split == "split"
    let cmd = ":split "
  elseif a:split == "vsplit"
    let cmd = ":vsplit "
  else
    let cmd = ":e "
  endif

  let link = s:strip_word(s:get_word_at_cursor(g:vimwiki_rxWikiLink))
  if link == ""
    let weblink = s:strip_word(s:get_word_at_cursor(g:vimwiki_rxWeblink))
    if weblink != ""
      call VimwikiWeblinkHandler(weblink)
    else
      execute "normal! \n"
    endif
    return
  endif

  let subdir = vimwiki#current_subdir()
  call vimwiki#open_link(cmd, subdir.link)

endfunction
" }}}

function! vimwiki#WikiGoBackWord() "{{{
  if exists("b:vimwiki_prev_link")
    " go back to saved WikiWord
    let prev_word = b:vimwiki_prev_link
    execute ":e ".substitute(prev_word[0], '\s', '\\\0', 'g')
    call setpos('.', prev_word[1])
  endif
endfunction
" }}}

function! vimwiki#WikiGoHome(index) "{{{
  call vimwiki#select(a:index)
  call vimwiki#mkdir(VimwikiGet('path'))

  try
    execute ':e '.fnameescape(
          \ VimwikiGet('path').VimwikiGet('index').VimwikiGet('ext'))
  catch /E37/ " catch 'No write since last change' error
    " this is really unsecure!!!
    execute ':'.VimwikiGet('gohome').' '.
          \ VimwikiGet('path').
          \ VimwikiGet('index').
          \ VimwikiGet('ext')
  catch /E325/ " catch 'ATTENTION' error (:h E325)
  endtry
endfunction
"}}}

function! vimwiki#WikiDeleteWord() "{{{
  "" file system funcs
  "" Delete WikiWord you are in from filesystem
  let val = input('Delete ['.expand('%').'] (y/n)? ', "")
  if val != 'y'
    return
  endif
  let fname = expand('%:p')
  try
    call delete(fname)
  catch /.*/
    echomsg 'vimwiki: Cannot delete "'.expand('%:t:r').'"!'
    return
  endtry
  execute "bdelete! ".escape(fname, " ")

  " reread buffer => deleted WikiWord should appear as non-existent
  if expand('%:p') != ""
    execute "e"
  endif
endfunction
"}}}

function! vimwiki#WikiRenameWord() "{{{
  "" Rename WikiWord, update all links to renamed WikiWord
  let subdir = vimwiki#current_subdir()
  let old_fname = subdir.expand('%:t')

  " there is no file (new one maybe)
  if glob(expand('%:p')) == ''
    echomsg 'vimwiki: Cannot rename "'.expand('%:p').
          \'". It does not exist! (New file? Save it before renaming.)'
    return
  endif

  let val = input('Rename "'.expand('%:t:r').'" (y/n)? ', "")
  if val!='y'
    return
  endif

  let new_link = input('Enter new name: ', "")

  if new_link =~ '[/\\]'
    " It is actually doable but I do not have free time to do it.
    echomsg 'vimwiki: Cannot rename to a filename with path!'
    return
  endif

  let new_link = subdir.new_link

  " check new_fname - it should be 'good', not empty
  if substitute(new_link, '\s', '', 'g') == ''
    echomsg 'vimwiki: Cannot rename to an empty filename!'
    return
  endif
  if s:is_link_to_non_wiki_file(new_link)
    echomsg 'vimwiki: Cannot rename to a filename with extension (ie .txt .html)!'
    return
  endif

  let new_link = s:strip_word(new_link)
  let new_fname = VimwikiGet('path').s:filename(new_link).VimwikiGet('ext')

  " do not rename if word with such name exists
  let fname = glob(new_fname)
  if fname != ''
    echomsg 'vimwiki: Cannot rename to "'.new_fname.
          \ '". File with that name exist!'
    return
  endif
  " rename WikiWord file
  try
    echomsg "Renaming ".VimwikiGet('path').old_fname." to ".new_fname
    let res = rename(expand('%:p'), expand(new_fname))
    if res != 0
      throw "Cannot rename!"
    end
  catch /.*/
    echomsg 'vimwiki: Cannot rename "'.expand('%:t:r').'" to "'.new_fname.'"'
    return
  endtry

  let &buftype="nofile"

  let cur_buffer = [expand('%:p'),
        \getbufvar(expand('%:p'), "vimwiki_prev_link")]

  let blist = s:get_wiki_buffers()

  " save wiki buffers
  for bitem in blist
    execute ':b '.escape(bitem[0], ' ')
    execute ':update'
  endfor

  execute ':b '.escape(cur_buffer[0], ' ')

  " remove wiki buffers
  for bitem in blist
    execute 'bwipeout '.escape(bitem[0], ' ')
  endfor

  let setting_more = &more
  setlocal nomore

  " update links
  call s:update_wiki_links(old_fname, new_link)

  " restore wiki buffers
  for bitem in blist
    if bitem[0] != cur_buffer[0]
      call s:open_wiki_buffer(bitem)
    endif
  endfor

  call s:open_wiki_buffer([new_fname,
        \ cur_buffer[1]])
  " execute 'bwipeout '.escape(cur_buffer[0], ' ')

  echomsg old_fname." is renamed to ".new_fname

  let &more = setting_more
endfunction
" }}}

function! vimwiki#WikiUISelect()"{{{
  call s:print_wiki_list()
  let idx = input("Select Wiki (specify number): ")
  if idx == ""
    return
  endif
  call vimwiki#WikiGoHome(idx)
endfunction
"}}}

" }}}

" TEXT OBJECTS functions {{{

function! vimwiki#TO_header(inner, visual) "{{{
  if !search('^\(=\+\).\+\1\s*$', 'bcW')
    return
  endif
  
  let sel_start = line("'<")
  let sel_end = line("'>")
  let block_start = line(".")
  let advance = 0

  let level = vimwiki#count_first_sym(getline('.'))

  let is_header_selected = sel_start == block_start 
        \ && sel_start != sel_end

  if a:visual && is_header_selected
    if level > 1
      let level -= 1
      call search('^\(=\{'.level.'\}\).\+\1\s*$', 'bcW')
    else
      let advance = 1
    endif
  endif

  normal! V

  if a:visual && is_header_selected
    call cursor(sel_end + advance, 0)
  endif

  if search('^\(=\{1,'.level.'}\).\+\1\s*$', 'W')
    call cursor(line('.') - 1, 0)
  else
    call cursor(line('$'), 0)
  endif

  if a:inner && getline(line('.')) =~ '^\s*$'
    let lnum = prevnonblank(line('.') - 1)
    call cursor(lnum, 0)
  endif
endfunction
"}}}

function! vimwiki#TO_table_cell(inner, visual) "{{{
  if col('.') == col('$')-1
    return
  endif

  if a:visual
    normal! `>
    let sel_end = getpos('.')
    normal! `<
    let sel_start = getpos('.')

    let firsttime = sel_start == sel_end

    if firsttime
      if !search('|\|\(-+-\)', 'cb', line('.'))
        return
      endif
      if getline('.')[virtcol('.')] == '+'
        normal! l
      endif
      if a:inner
        normal! 2l
      endif
      let sel_start = getpos('.')
    endif

    normal! `>
    call search('|\|\(-+-\)', '', line('.'))
    if getline('.')[virtcol('.')] == '+'
      normal! l
    endif
    if a:inner
      if firsttime || abs(sel_end[2] - getpos('.')[2]) != 2
        normal! 2h
      endif
    endif
    let sel_end = getpos('.')

    call setpos('.', sel_start)
    exe "normal! \<C-v>"
    call setpos('.', sel_end)

    " XXX: WORKAROUND.
    " if blockwise selection is ended at | character then pressing j to extend
    " selection furhter fails. But if we shake the cursor left and right then
    " it works.
    normal! hl
  else
    if !search('|\|\(-+-\)', 'cb', line('.'))
      return
    endif
    if a:inner
      normal! 2l
    endif
    normal! v
    call search('|\|\(-+-\)', '', line('.'))
    if !a:inner && getline('.')[virtcol('.')-1] == '|'
      normal! h
    elseif a:inner
      normal! 2h
    endif
  endif
endfunction "}}}

function! vimwiki#TO_table_col(inner, visual) "{{{
  let t_rows = vimwiki_tbl#get_rows(line('.'))
  if empty(t_rows)
    return
  endif

  " TODO: refactor it!
  if a:visual
    normal! `>
    let sel_end = getpos('.')
    normal! `<
    let sel_start = getpos('.')

    let firsttime = sel_start == sel_end

    if firsttime
      " place cursor to the top row of the table
      call s:cursor(t_rows[0][0], virtcol('.'))
      " do not accept the match at cursor position if cursor is next to column
      " separator of the table separator (^ is a cursor):
      " |-----^-+-------|
      " | bla   | bla   |
      " |-------+-------|
      " or it will select wrong column.
      if strpart(getline('.'), virtcol('.')-1) =~ '^-+'
        let s_flag = 'b'
      else
        let s_flag = 'cb'
      endif
      " search the column separator backwards
      if !search('|\|\(-+-\)', s_flag, line('.'))
        return
      endif
      " -+- column separator is matched --> move cursor to the + sign
      if getline('.')[virtcol('.')] == '+'
        normal! l
      endif
      " inner selection --> reduce selection
      if a:inner
        normal! 2l
      endif
      let sel_start = getpos('.')
    endif

    normal! `>
    if !firsttime && getline('.')[virtcol('.')] == '|'
      normal! l
    elseif a:inner && getline('.')[virtcol('.')+1] =~ '[|+]'
      normal! 2l
    endif
    " search for the next column separator
    call search('|\|\(-+-\)', '', line('.'))
    " Outer selection selects a column without border on the right. So we move
    " our cursor left if the previous search finds | border, not -+-.
    if getline('.')[virtcol('.')] != '+'
      normal! h
    endif
    if a:inner
      " reduce selection a bit more if inner.
      normal! h
    endif
    " expand selection to the bottom line of the table
    call s:cursor(t_rows[-1][0], virtcol('.'))
    let sel_end = getpos('.')

    call setpos('.', sel_start)
    exe "normal! \<C-v>"
    call setpos('.', sel_end)

  else
    " place cursor to the top row of the table
    call s:cursor(t_rows[0][0], virtcol('.'))
    " do not accept the match at cursor position if cursor is next to column
    " separator of the table separator (^ is a cursor):
    " |-----^-+-------|
    " | bla   | bla   |
    " |-------+-------|
    " or it will select wrong column.
    if strpart(getline('.'), virtcol('.')-1) =~ '^-+'
      let s_flag = 'b'
    else
      let s_flag = 'cb'
    endif
    " search the column separator backwards
    if !search('|\|\(-+-\)', s_flag, line('.'))
      return
    endif
    " -+- column separator is matched --> move cursor to the + sign
    if getline('.')[virtcol('.')] == '+'
      normal! l
    endif
    " inner selection --> reduce selection
    if a:inner
      normal! 2l
    endif

    exe "normal! \<C-V>"

    " search for the next column separator
    call search('|\|\(-+-\)', '', line('.'))
    " Outer selection selects a column without border on the right. So we move
    " our cursor left if the previous search finds | border, not -+-.
    if getline('.')[virtcol('.')] != '+'
      normal! h
    endif
    " reduce selection a bit more if inner.
    if a:inner
      normal! h
    endif
    " expand selection to the bottom line of the table
    call s:cursor(t_rows[-1][0], virtcol('.'))
  endif
endfunction "}}}

function! vimwiki#count_first_sym(line) "{{{
  let first_sym = matchstr(a:line, '\S')
  return len(matchstr(a:line, first_sym.'\+'))
endfunction "}}}

function! vimwiki#AddHeaderLevel() "{{{
  let lnum = line('.')
  let line = getline(lnum)

  if line =~ '^\s*$'
    return
  endif

  if line =~ '^\s*\(=\+\).\+\1\s*$'
    let level = vimwiki#count_first_sym(line)
    if level < 6
      let line = substitute(line, '\(=\+\).\+\1', '=&=', '')
      call setline(lnum, line)
    endif
  else
      let line = substitute(line, '^\s*', '&= ', '')
      let line = substitute(line, '\s*$', ' =&', '')
      call setline(lnum, line)
  endif
endfunction
"}}}

function! vimwiki#RemoveHeaderLevel() "{{{
  let lnum = line('.')
  let line = getline(lnum)

  if line =~ '^\s*$'
    return
  endif

  if line =~ '^\s*\(=\+\).\+\1\s*$'
    let level = vimwiki#count_first_sym(line)
    let old = repeat('=', level)
    let new = repeat('=', level - 1)

    let chomp = line =~ '=\s'

    let line = substitute(line, old, new, 'g')

    if level == 1 && chomp
      let line = substitute(line, '^\s', '', 'g')
      let line = substitute(line, '\s$', '', 'g')
    endif
    call setline(lnum, line)
  endif
endfunction
" }}}

" }}}
