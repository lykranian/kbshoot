## kbshoot

bash script for taking screenshots and sharing through kbfs

OUTDATED / MERGED INTO MAIN SHOOT SCRIPT

#### usage

`kbshoot -h`

```
simple screenshot script for kbfs
https image link is copied to clipboard

requires keybase+kbfs

usage : kbshoot
      : kbshoot -s
      : kbshoot filename

 args : none        fullscreen
      : -s          select area
      : filename    upload file
      : -h --help   show this help

 deps : maim+slop OR scrot
      : pngcrush
      : libimage-exiftool-perl
      : keybase
      : xclip
```

#### to do

 - delete single file
 - delete all files
 - ~~get keybase user through api~~
 - multiple filename options
  - preserve filename
  - rand
  - timestamp