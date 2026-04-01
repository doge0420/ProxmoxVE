#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: doge0420
# License: MIT | https://github.com/doge0420/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/lyqht/mini-qr

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt install -y \
  libharfbuzz0b \
  caddy \
  fontconfig
msg_ok "Installed Dependencies"

NODE_VERSION="22" NODE_MODULE="pnpm" setup_nodejs

fetch_and_deploy_gh_release "mini-qr" "lyqht/mini-qr" "tarball" "latest" "/opt/mini-qr"

msg_info "Setting up MiniQR"

cat <<EOF >/opt/mini-qr/.env
BASE_PATH=/
VITE_HIDE_CREDITS="false"
VITE_DEFAULT_PRESET=""
VITE_DEFAULT_DATA_TO_ENCODE=""
VITE_QR_CODE_PRESETS="[]"
VITE_FRAME_PRESET=""
VITE_FRAME_PRESETS="[]"
VITE_DISABLE_LOCAL_STORAGE="false"
EOF

msg_ok "Set up MiniQR"

msg_info "Building MiniQR"

cd /opt/mini-qr || exit

$STD pnpm ci --production
$STD pnpm run build

msg_ok "Built MiniQR"

msg_info "Configuring Caddy"
cat <<EOF >/etc/caddy/Caddyfile
:80 {
    root * /opt/mini-qr/dist
    file_server
}
EOF
systemctl enable -q --now caddy

msg_ok "Configured Caddy"

motd_ssh
customize
cleanup_lxc
