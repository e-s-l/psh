# A Shell in Perl

## Summary

This is a quick crack at a shell.

Using perl because:

    - Easy to get into the concepts, without getting bogged in C,
    - Perl has the fork() &c similiar to C, so learning some things

In the end:

    - perl packages make it almost trivial,
    - got caught up in perl function references...
	- but had fun implementing the built-ins.

## The Program

### set-up

You need to add via your package manager `perl-TermReadLine-Gnu`, probably, for
the up-for-history functionality.

Weasel is optional, and perhaps ill-advised.

### about

Follows a minimal shell structure.

Included an annoying welcome message which is implmeneted by a 'weasel'
animation (it's not actually an implementation of the dawkin's weasel
evolutionary program but has some similiarity).

### Structure

- Tried to apply something of the proper structure of a terminal, see the
  accompanying notes.

********************

### TODO

- create a command table... have sort of done this with the builtins hash...
- subsystems
- flags and wildcards can be implemented by arent...

#### wildcards

- the wildcards to need search subdirectories, directories specified
- also need single character matching with `?`
- wildcards should also sort, and not match hidden files/directories unless `.*`
- try to reimplement the behaviour of `echo *` or `ls *`.
- matching subdirectories along the search path, try to implement the expandWildcard(prefix, suffix) funciton suggested in *SystemsProgramming*

#### tab completion

- right now tab use globbing but should also match simple commands, or commands in the path...

************

## The Theory

To copy across from a obsidian note when that's fleshed out.


***********

## Weasel

Had a crack at implementing this as a module.


***********

## references

- https://brennan.io/2015/01/16/write-a-shell-in-c/
- https://www.cs.purdue.edu/homes/grr/SystemsProgrammingBook/Book/Chapter5-WritingYourOwnShell.pdf
