To run this on your machine, ensure you update the fully-qualified
path in `syscall-test.amb`. The other two files are relative paths and
should not need any edits.

If you want to do multiple hop tests you need to manually edit

  - `open-read-write.c` -- change `CONTAINING_DIRECTORY`
  - `syscall-test.amb` -- change the second to last argument to
    syscall-test
  - `test.sh` -- change `TEST_FILE`
