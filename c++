#!/bin/sh
exec /usr/bin/c++ -Wno-maybe-uninitialized -fno-diagnostics-show-caret "$@"
