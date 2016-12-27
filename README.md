# vim-list2tree

Change to tree from list of markdown plugin.

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
