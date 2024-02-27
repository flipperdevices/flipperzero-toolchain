#!/bin/bash

set -euo pipefail;

grep -rIl '#!/toolchain/mac-arm64-output-root/bin/python3' /toolchain/mac-arm64-output-root/ | xargs sed -i '' 's/#!\/toolchain\/mac-arm64-output-root\/bin\/python3/#!\/usr\/bin\/env python3/g';

grep -rIl '#!/toolchain/mac-x86_64-output-root/bin/python3' /toolchain/mac-x86_64-output-root/ | xargs sed -i '' 's/#!\/toolchain\/mac-x86_64-output-root\/bin\/python3/#!\/usr\/bin\/env python3/g';
