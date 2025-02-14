#!/bin/bash

if [ -f /frpc.toml ] && [ -n "$HP_SHARED_KEY" ]; then
  if pgrep -x "frpc" > /dev/null; then
      exit 0
  else
      exit 1
  fi
fi
