# Archives the function knows how to handle come first; directories stay in the
# list so you can descend into them. -k keeps __fish_complete_suffix's ordering,
# which fish would otherwise re-sort alphabetically.
complete -c ex -f -k -a '(__fish_complete_suffix .tar.bz2 .tar.gz .tar.xz .tar.zst .tar .tbz2 .tgz .bz2 .gz .zip .rar .7z .Z .deb)'
