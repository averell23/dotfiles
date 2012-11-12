# Stolen from https://github.com/nono/dotfiles/blob/master/zsh/Completion/_bundler

_bundle () {

  #compdef bundle

  local curcontext="$curcontext" state line _gems _opts ret=1

  _arguments -C -A "-v" -A "--version" \
  '(- 1 *)'{-v,--version}'[display version information]' \
  '1: :->cmds' \
  '*:: :->args' && ret=0

  case $state in
  cmds)
  _values "bundle command" \
  "install[Install the gems specified by the Gemfile or Gemfile.lock]" \
  "update[Update dependencies to their latest versions]" \
  "package[Package the .gem files required by your application]" \
  "exec[Execute a script in the context of the current bundle]" \
  "config[Specify and read configuration options for bundler]" \
  "check[Determine whether the requirements for your application are installed]" \
  "list[Show all of the gems in the current bundle]" \
  "show[Show the source location of a particular gem in the bundle]" \
  "console[Start an IRB session in the context of the current bundle]" \
  "open[Open an installed gem in the editor]" \
  "viz[Generate a visual representation of your dependencies]" \
  "init[Generate a simple Gemfile, placed in the current directory]" \
  "gem[Create a simple gem, suitable for development with bundler]" \
  "help[Describe available tasks or one specific task]"
  ret=0
  ;;
  args)
  case $line[1] in
  help)
  _values 'commands' 'install update package exec config check list show console open viz init gem help' && ret=0
  ;;
  install)
  _arguments \
  '(--no-color)--no-color[disable colorization in output]' \
  '(--local)--local[do not attempt to connect to rubygems.org]' \
  '(--quiet)--quiet[only output warnings and errors]' \
  '(--gemfile)--gemfile=-[use the specified gemfile instead of Gemfile]:gemfile' \
  '(--system)--system[install to the system location]' \
  '(--deployment)--deployment[install using defaults tuned for deployment environments]' \
  '(--frozen)--frozen[do not allow the Gemfile.lock to be updated after this install]' \
  '(--path)--path=-[specify a different path than the system default]:path:_files' \
  '(--binstubs)--binstubs=-[generate bin stubs for bundled gems to ./bin]:directory:_files' \
  '(--without)--without=-[exclude gems that are part of the specified named group]:groups'
  ret=0
  ;;
  exec)
  _normal && ret=0
  ;;
  (open|show)
  _gems=( $(bundle show 2> /dev/null | sed -e '/^ \*/!d; s/^ \* \([^ ]*\) .*/\1/') )
  if [[ $_gems != "" ]]; then
  _values 'gems' $_gems && ret=0
  fi
  ;;
  *)
  _opts=( $(bundle help $line[1] | sed -e '/^ \[-/!d; s/^ \[\(-[^=]*\)=.*/\1/') )
  _opts+=( $(bundle help $line[1] | sed -e '/^ -/!d; s/^ \(-.\), \[\(-[^=]*\)=.*/\1 \2/') )
  if [[ $_opts != "" ]]; then
  _values 'options' $_opts && ret=0
  fi
  ;;
  esac
  ;;
  esac

  return ret

}

compdef _bundle bundle