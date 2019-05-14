#!/bin/bash

set -euo pipefail
set -x

diff $1 $2
