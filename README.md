homeclean
=========

A utility to clean your GNU/Linux's home by deleting the files that have not
been accessed for a long time (by default, 365 days). Written in GNU Bash.

:warning: Alpha testers needed
------------------------------

`homeclean` is in alpha stage! Please help me by reporting any issue
[here](https://github.com/cszach/homeclean/issues). Thank you!

Table of content
----------------

1. [Download](#download)
2. [Use](#use)
   1. [Getting started](#getting-started)
   2. [Clean behavior](#clean-behavior)
   3. [Configure](#configure)
   4. [`.homecleaninclude`](#homecleaninclude)
   5. [Miscellaneous options](#miscellaneous-options)
   6. [Help information](#help-information)
3. [To-do](#to-do)

Download
--------

```bash
git clone https://github.com/cszach/homeclean
cd homeclean
./install
```

Use
---

### Getting started

`homeclean` uses the `find` command to search for files that have not been
accessed for, by default, 365 days. We will see how to change the number of days
in a second. But first, try:

```bash
homeclean --dry
```

This will print the files that `homeclean` would remove, without actually
removing them. If there is no file, the message "`No files to clean.`" will
appear. You can change the number of days e.g. decrease it to expand the search,
using the `-a` option:

```bash
homeclean --dry -a180 # Search for files that have not been accessed for 6 months
```

**It is recommended that you carefully view the list of files before cleaning
them using `homeclean`.** The utility may pick up files that you do not wish to
delete, such as your backups or program files. This is where the file
`.homecleanignore` comes in.

`.homecleanignore` is where you can specify files and directories that you want
`homeclean` to ignore (similar to `.gitignore` for Git). The file must be at the
root of your `$HOME` directory (i.e. `$HOME/.homecleanignore`). Here is an
example of a `.homecleanignore` file:

```
# Ignore dot files and folders

.*

# Ignore backups

/home/john/Backup
```

<a name="dot-file-rules">Note:</a>
- Blank lines are ignored;
- Lines that start with the hash symbol (`#`) are considered comments and are
  ignored by `homeclean`. You cannot have a comment and a pattern on the same
  line;
- Each pattern appears on its own line;
- Shell patterns (wildcards) are allowed, such as `.*` (matches hidden files and
  folders);
- If a pattern does not match absolute paths, then it will be concatenated to
  `HOMECLEAN_INCLUDE` directories, which is `$HOME` by default. In the above
  example, `.*` is a pattern that does not match absolute paths, so it will be
  concatenated to `$HOME`, meaning the entry `.*` is the same as `/home/john/.*`.
  On the other hand, `/home/john/Backup` is a pattern that matches an absolute
  path, so it is not concatenated to anything.

Once you are happy with the list of files, clean them by removing the `--dry`
option:

```bash
homeclean
```

The list of files will be displayed, and `homeclean` will ask for your
confirmation. Again, **be sure to review the list before cleaning**. Enter `y`
or `yes` to confirm.

### Clean behavior

By default, `homeclean` does not actually delete the files. It will instead
"trash" them, by moving them to a directory called `.homecleantrash`. The full
path of this directory is `$HOME/.homecleantrash`. When trashing files, their
parent directories are preserved in the trash folder. For example, if a file at
`/home/john/a/b/c/old_file.txt` is trashed, it will be moved to
`/home/john/.homecleantrash/home/john/a/b/c/old_file.txt`. This makes it
possible to restore the trashed files back to their original positions later. If
you do not want to preserve parent directories, use the `-l` option:

```
homeclean -l
```

`old_file.txt` would be moved to `/home/john/.homecleantrash/old_file.txt` in
this case.

If you want to delete the files permanently instead of moving them to trash, use
the `-x` or `--delete` option:

```
homeclean --delete
```

### Configure

```
homeclean --show-config
```

…shows the current configuration of `homeclean`. The meaning of the variables
are explained in the help information, which can be displayed using:

```
homeclean --help
```

To change the configuration, you can edit the `~/.homecleanrc` file. If it does
not already exist, export the current configuration using:

```
homeclean --export-config --dry
```

### `.homecleaninclude`

`homeclean` searches in `$HOME` by default, but you can override this behavior.
The `.homecleaninclude` file (which must be stored at `$HOME/.homecleaninclude`)
can be used to specify the directories and files for `homeclean` to search. The
syntax for the file is the same as for `.homecleanignore` (see
[above](#dot-file-rules)).

### Miscellaneous options

Finally, some options that have not been mentioned:

- `--ignore-hidden=TYPE` allows you to ignore hidden files and directories.
  `TYPE` can be `all` (ignore both hidden files and directories), `directories`
  (only directories), or `files` (only files);
- `-N` or `--non-recursive` allows you to search for files non-recursively. `R`
  or `--recursive` overrides this behavior;
- `--show-command` prints the `find` command that `homeclean` uses to search for
  files to clean under the current configuration. You can save the output to a
  script:

```bash
homeclean --show-command > script.sh
```

  or use it in your scripts, like this:

```bash
OLD_FILES=$( eval "$( homeclean --show-command )" )
```

- Using `--cron` means `homeclean` will not ask you for your confirmation. This
  is suitable for, say, using `homeclean` in a cronjob. Use this option with
  serious caution.

### Help information

Whenever you get stuck, the help information is your friend. Print it with:

```
homeclean --help
```

To-do
-----

- [ ] Restore trashed files
- [ ] `--export-config` only exports config

Contributions are very welcomed!
