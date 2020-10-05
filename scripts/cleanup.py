#!/usr/bin/env python3
# -------------------------------------------------------------------------------------------------
#  Copyright (C) 2015-2020 Nautech Systems Pty Ltd. All rights reserved.
#  https://nautechsystems.io
#
#  Licensed under the GNU Lesser General Public License Version 3.0 (the "License");
#  You may not use this file except in compliance with the License.
#  You may obtain a copy of the License at https://www.gnu.org/licenses/lgpl-3.0.en.html
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# -------------------------------------------------------------------------------------------------

"""
A utility script to remove cython and pytest artifact files from source code directories.
"""

import os
import shutil

EXTENSIONS_TO_CLEAN = (".c", ".so", ".o", ".pyd", ".pyc", ".dll", ".html")


if __name__ == "__main__":
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    print(f"{root_dir=}")

    for target in [".pytest_cache", "__pycache__", "build", "dist"]:
        shutil.rmtree(os.path.join(root_dir, target), ignore_errors=True)

    removed_count = 0
    for directory in [os.path.join(root_dir, "nautilus_trader")]:
        for root, _dirs, files in os.walk(directory):
            for name in files:
                path = os.path.join(root, name)
                if os.path.isfile(path) and path.endswith(EXTENSIONS_TO_CLEAN):
                    os.remove(path)
                    removed_count += 1
    print(f"Removed {removed_count} discrete files by extension.")
