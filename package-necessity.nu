#! /usr/bin/env nu

def 'pkg from info get name' [] {
  lines
    | where {|line| $line | str starts-with 'Name'}
    | each {|line| $line | str replace 'Name\s*:\s*' ''}
}

def 'pkg from info get repo' [] {
  lines
    | where {|line| $line | str starts-with 'Repository'}
    | each {|line| $line | str replace 'Repository\s*:\s*' ''}
}

def 'pkg from info get name-repo' [] {
  let info = $in
  let names = ($info | pkg from info get name)
  let repos = ($info | pkg from info get repo)
  $names
    | zip $repos
    | each {|x| [[name repo]; [$x.0 $x.1]]}
    | flatten
    | group-by name
    | transpose name info
    | insert repo {|x| $x.info | get repo}
    | reject info
}

def load-pkg-name [] {
  open init-aur-builder.yaml | get aur-package-names
}

def 'pkg from name get info' [] {
  pacman -Si $in
}

def 'pkg from name get repo' [] {
  pkg from name get info | pkg from info get name-repo
}

def 'pkg repo is-needed' [repo: list] {
  $repo | all {|repo| $repo == 'khai' or $repo == 'aur'}
}

def show-data [] {
  load-pkg-name
    | pkg from name get repo
    | insert needed {|x| pkg repo is-needed $x.repo}
    | update repo {|x| $x.repo | str join ', '}
}

def main [command: string] {
  if $command == 'all' {
    show-data
  } else if $command == 'needed' {
    show-data | where needed
  } else if $command == 'unneeded' {
    show-data | where not needed
  } else {
    let span = (metadata $command).span
    error make {
      msg: 'Invalid command: Must be either "all", "needed", or "unneeded"'
      start: span.start
      end: span.end
    }
  }
}
