#! /usr/bin/env nu

def pkg-repo [name: string] {
  pacman -Si $name
    | lines
    | where {|line| $line | str starts-with 'Repository'}
    | each {|line| $line | str replace 'Repository\s*:\s*' ''}
}

def is-pkg-needed [name: string] {
  pkg-repo $name | all {|repo| $repo == 'khai' || $repo == 'aur'}
}

def main [] {
  open ./init-aur-builder.yaml
    | get aur-package-names
    | where {|name| not (is-pkg-needed $name)}
}
