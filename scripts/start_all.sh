#!/usr/bin/env bash
# Copyright © 2023 OpenIM. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#FIXME This script is the startup script for multiple servers.
#FIXME The full names of the shell scripts that need to be started are placed in the `need_to_start_server_shell` array.

set -o nounset
set -o pipefail

OPENIM_ROOT=$(dirname "${BASH_SOURCE[0]}")/..
source "${OPENIM_ROOT}/scripts/install/common.sh"

set +o errexit
openim::golang::check_openim_binaries
if [[ $? -ne 0 ]]; then
  openim::log::error "OpenIM binaries are not found. Please run 'make build' to build binaries."
  ${OPENIM_ROOT}/scripts/build_all_service.sh
fi
set -o errexit

echo "You need to start the following scripts in order: ${OPENIM_SERVER_SCRIPTARIES[@]}"
openim::log::install_errexit

# Function to execute the scripts.
function execute_scripts() {
    for script_path in "${OPENIM_SERVER_SCRIPT_START_LIST[@]}"; do
        # Check if the script file exists and is executable.
        if [[ -x "$script_path" ]]; then
            openim::log::status "Starting script: ${script_path##*/}"     # Log the script name.
            
            # Execute the script.
            "$script_path"

            # Check if the script executed successfully.
            if [[ $? -eq 0 ]]; then
                openim::log::info "${script_path##*/} executed successfully."
            else
                openim::log::errexit "Error executing ${script_path##*/}."
            fi
        else
            openim::log::errexit "Script ${script_path##*/} is missing or not executable."
        fi
    done
}

execute_scripts