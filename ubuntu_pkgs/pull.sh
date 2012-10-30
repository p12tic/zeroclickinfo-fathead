#!/bin/bash

table='<table id="ubuntuVersions">';
header='<tr><th>Ubuntu Version</th><th>Package Version</th><th>Architecture</th></tr>';
end_table='</table>';

for pkg in $(awk '{print $1}' pkg.lst); do
  DATA="$( curl \
   'http://qa.debian.org/madison.php?package='"$pkg"'&table=ubuntu&a=&c=&s=&text=on#' \
   2>/dev/null )";
  for line in 1 2 3; do
    distro="<tr>$(echo "$DATA" | sed -n "$line"p | awk -F\| '{print $3}')</tr>";
    arch="<tr>$(echo "$DATA" | sed -n "$line"p | awk -F\| '{print $4}')</tr>";
    sed -n "/^$pkg\t/"p pkg.lst \
      | perl -ne "chomp; print \$_, '$table$header' if $line == 1; print \"$distro$arch\"";
  done;
  echo "$end_table";
done;
