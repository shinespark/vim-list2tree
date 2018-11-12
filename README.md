# vim-list2tree

Convert a markdown list format to a tree format.

## Usage

Write directories / files by list.

```
* .
  * dir
    * file
    * file
    * file
  * dir
    * dir
      * file
      * file
  * file
```

Select target lines by linewise-visual, type `:'<,'>List2Tree` .

```
.
├── dir
│   ├── file
│   ├── file
│   └── file
├── dir
│   └── dir
│       ├── file
│       └── file
└── file
```


If you need to use keymapping, add this vim setting.

```
vnoremap <c-t> :<c-u>'<,'>List2Tree<CR>
```

## Install

### dein.vim

```
call dein#add('shinespark/vim-list2tree', {'lazy': 1, 'on_cmd': 'List2Tree'})
```
