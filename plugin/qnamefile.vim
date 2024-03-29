"=============================================================================
" File: qnamefile.vim
" Author: batman900 <batman900+vim@gmail.com>
" Last Change: 5/12/2011
" Version: 0.07

if v:version < 700
	finish
endif

if exists("g:qnamefile_loaded") && g:qnamefile_loaded
	finish
endif
let g:qnamefile_loaded = 1

if !exists("g:qnamefile_hotkey") || g:qnamefile_hotkey == ""
	let g:qnamefile_hotkey = "<S-F4>"
endif

if !hasmapto('QNameFileInit')
	exe "nmap <unique>" g:qnamefile_hotkey ":call QNameFileInit('', '', 0)<cr>:~"
endif

let s:qnamefile_hotkey = eval('"\' . g:qnamefile_hotkey . '"')

let g:qnamefile_height = 0
let g:qnamefile_leader = 0
let g:qnamefile_regexp = 0

" Find all files from path of the given extension ignoring hidden files
" a:path Where to start searching from
" a:extensions A space separated list of extensions to filter on (e.g. "java cpp h")
function! QNameFileInit(path, extensions, include_hidden, ignore_paths)
	let path = a:path
	if path != ""
	  let path = ""
	  for path_part in split(a:path, " ")
      if isdirectory(path_part)
        let path = path . path_part . " "
      end
    endfor
  else
		let path = '.'
	endif
	let ext = ''
	if a:extensions
		let ext = join(split(a:extensions, ' '), '\|')
		let ext = '-and -regex ".*/.*\.\(' . ext . '\)"'
	endif
	let hidden = ''
	if !a:include_hidden
		let hidden = '-not -regex ".*/\..*"'
	endif
	let ignore_paths = [".git", ".svn"]
	if a:ignore_paths != ""
    let ignore_paths = ignore_paths + split(a:ignore_paths, ",")
  end
  let ignore = ""
  for ignore_path in ignore_paths
    let ignore = ignore . " -name " . ignore_path . " -prune -o"
  endfor
	"let ofnames = sort(split(system('find ' . a:path . ' -type f ' . hidden . ' ' . ext . ' -print'), "\n"))
	let ofnames = sort(split(system('find ' . path . ignore . " -not -type f -o -print"), "\n"))
	let g:cmd_arr = map(ofnames, "fnamemodify(v:val, ':.')")
	call QNamePickerStart(g:cmd_arr, {
				\ "complete_func": function("QNameFileCompletion"),
				\ "acceptors": ["v", "s", "t", "\<M-v>", "\<M-s>", "\<M-t>", "\<C-v>", "\<C-s>", "\<C-t>"],
				\ "cancelors": ["g", "\<C-g>", s:qnamefile_hotkey],
				\ "regexp": g:qnamefile_regexp,
				\ "use_leader": g:qnamefile_leader,
				\ "height": g:qnamefile_height,
				\})
endfunction

function! QNameFileCompletion(index, key)
	if a:key == "s" || a:key == "\<M-s>" || a:key == "\<C-s>"
		let cmd = "sp"
	elseif a:key == "v" || a:key == "\<M-v>" || a:key == "\<C-v>"
		let cmd = "vert sp"
	elseif a:key == "t" || a:key == "\<M-t>" || a:key == "\<C-t>"
		let cmd = "tabe"
	else
		let cmd = "e"
	endif
	exe ':' . cmd . ' ' . g:cmd_arr[a:index]
	unlet g:cmd_arr
endfunction
