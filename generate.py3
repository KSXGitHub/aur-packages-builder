#! /usr/bin/python3
from subprocess import run
from os import path, chdir
from sys import exit, stderr
import yaml

def exec(*args: str):
  status = run(args).returncode
  if status == 0: return
  print(f'::error::Process exits with non-zero status code: {status}')
  exit(status)

root = path.dirname(__file__)
chdir(root)

package_list = yaml.load(open('packages.yaml'))
if type(package_list) != list:
  print('::error::Content of packages.yaml is not a list')
  exit(1)

for package_name in package_list:
  if type(package_name) != str:
    print('::error::One of the package names is not a string')
    exit(1)
  print('📦', package_name, file=stderr, flush=True)
  exec('git', 'clone', '--depth=1', f'https://aur.archlinux.org/{package_name}.git', path.join('build', package_name))
  print(file=stderr, flush=True)
