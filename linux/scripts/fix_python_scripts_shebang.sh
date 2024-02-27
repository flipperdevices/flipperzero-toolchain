#!/bin/bash

set -euo pipefail;

grep -rIl '#!/toolchain/linux-output-root/bin/python3' /toolchain/linux-output-root/ | xargs sed -i 's/#!\/toolchain\/linux-output-root\/bin\/python3/#!\/usr\/bin\/env python3/g';
