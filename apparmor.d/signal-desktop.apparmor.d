# apparmor.d - Full set of apparmor profiles
# Copyright (C) 2018-2021 Mikhail Morfikov
# Copyright (C) 2023-2024 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: GPL-2.0-only

abi <abi/4.0>,

include <tunables/global>

@{name} = signal-desktop{,-beta}
@{domain} = org.chromium.Chromium
@{lib_dirs} = @{lib}/signal-desktop /opt/Signal{,?Beta}
@{config_dirs} = @{user_config_dirs}/Signal{,?Beta}
@{cache_dirs} = @{user_cache_dirs}/@{name}

@{exec_path} = @{lib_dirs}/@{name}
@{att} = /att/signal-desktop/
profile signal-desktop /{{,usr/}lib{,exec,32,64}/signal-desktop/signal-desktop{,-beta},opt/Signal{,?Beta}/signal-desktop{,-beta}} flags=(attach_disconnected,attach_disconnected.path=@{att},complain) {
  include <abstractions/attached/base>
  include <abstractions/audio-client>
  include <abstractions/bluetooth-observe>
  include <abstractions/bus-system>
  include <abstractions/camera>
  include <abstractions/common/electron>
  include <abstractions/devices-usb-read>
  include <abstractions/screen-inhibit>
  include <abstractions/screensaver>
  include <abstractions/secrets-service>
  include <abstractions/user-download-strict>

  network inet dgram,
  network inet6 dgram,
  network inet stream,
  network inet6 stream,
  network netlink raw,

  @{exec_path} mrix,

  @{open_path}         rpx -> child-open-strict,

  owner @{user_config_dirs}/signal-desktop-flags.conf r,

  include if exists <local/signal-desktop>
}

# vim:syntax=apparmor
