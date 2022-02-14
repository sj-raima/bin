#!/bin/sh
exec /usr/bin/cc -Wno-maybe-uninitialized -fno-diagnostics-show-caret "$@"
