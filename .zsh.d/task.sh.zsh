################################################################################
# bash completion support for taskwarrior
# taskwarrior - a command line task list manager.
#
# Copyright 2006-2012, Paul Beckingham, Federico Hernandez.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# http://www.opensource.org/licenses/mit-license.php
#
################################################################################
#
# The routines will do completion of:
#
#    *) task subcommands
#    *) project names
#    *) tag names
#
# To use these routines:
#
#    1) Copy this file to somewhere (e.g. ~/.bash_completion.d/task.sh).
#    2) Add the following line to your .bashrc:
#        source ~/.bash_completion.d/task.sh
#
#    OR
#
#    3) Copy the file to /etc/bash_completion.d
#    4) source /etc/bash_completion
#
# To submit patches/bug reports:
#
#    *) Go to the project's website at
#
#       http://taskwarrior.org
#
################################################################################

_task_get_tags() {
    task _tags
}

_task_get_config() {
    task _config
}

_task_offer_dependencies() {
    COMPREPLY=( $(compgen -W "$(task _ids)" -- ${cur/*:/}) )
}

_task_offer_priorities() {
    COMPREPLY=( $(compgen -W "L M H" -- ${cur/*:/}) )
}

_task_offer_projects() {
    COMPREPLY=( $(compgen -W "$(task _projects)" -- ${cur/*:/}) )
}

_task() 
{
    local cur prev opts base

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    if [ ${#COMP_WORDS[*]} -gt 2 ]
    then
        prev2="${COMP_WORDS[COMP_CWORD-2]}"
    else
        prev2=""
    fi
#   echo -e "\ncur='$cur'"
#   echo "prev='$prev'"
#   echo "prev2='$prev2'"

    opts="$(task _commands) $(task _ids) $(task _columns)"

    case "${prev}" in
        :)
            case "${prev2}" in
                dep*)
                    _task_offer_dependencies
                    return 0
                    ;;
                pri*)
                    _task_offer_priorities
                    return 0
                    ;;
                pro*)
                    _task_offer_projects
                    return 0
                    ;;
            esac
            ;;
        *)
            case "${cur}" in
                pro*:*)
                    _task_offer_projects
                    return 0
                    ;;
                :)
                    case "${prev}" in
                        dep*)
                            _task_offer_dependencies
                            return 0
                            ;;
                        pri*)
                            _task_offer_priorities
                            return 0
                            ;;
                        pro*)
                            _task_offer_projects
                            return 0
                            ;;
                    esac
                    ;;
                +*)
                    local tags=$(_task_get_tags | sed 's/^/+/')
                    COMPREPLY=( $(compgen -W "${tags}" -- ${cur}) )
                    return 0
                    ;;
                -*)
                    local tags=$(_task_get_tags | sed 's/^/-/')
                    COMPREPLY=( $(compgen -W "${tags}" -- ${cur}) )
                    return 0
                    ;;
                rc.*)
                    local config=$(_task_get_config | sed -e 's/^/rc\./' -e 's/$/:/')
                    COMPREPLY=( $(compgen -W "${config}" -- ${cur}) )
                    return 0
                    ;;
						 *)
 						  case "${prev}" in
							  merge)
								 local servers=$(_task_get_config | grep merge | grep uri | sed 's/^merge\.\(.*\)\.uri/\1/')
								 COMPREPLY=( $(compgen -W "${servers}" -- ${cur}) )
								 _known_hosts_real -a "$cur"
						       return 0
						       ;;
							  push)
								 local servers=$(_task_get_config | grep push | grep uri | sed 's/^push\.\(.*\)\.uri/\1/')
								 COMPREPLY=( $(compgen -W "${servers}" -- ${cur}) )
								 _known_hosts_real -a "$cur"
						       return 0
						       ;;
							  pull)
								 local servers=$(_task_get_config | grep pull | grep uri | sed 's/^pull\.\(.*\)\.uri/\1/')
								 COMPREPLY=( $(compgen -W "${servers}" -- ${cur}) )
								 _known_hosts_real -a "$cur"
						       return 0
						       ;;
							  import)
								 COMPREPLY=( $(compgen -o "default" -- ${cur}) )
								 return 0
								 ;;
						  esac
						  ;;
            esac
            ;;
    esac
      
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
}
complete -o nospace -F _task task
