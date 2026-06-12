# apparmor.d - Full set of apparmor profiles
# Copyright (C) 2022-2024 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: GPL-2.0-only

abi <abi/4.0>,

include <tunables/global>

@{exec_path} = @{bin}/wg-quick
@{att} = /att/wg-quick/
profile wg-quick /{,usr/}bin/wg-quick flags=(attach_disconnected,attach_disconnected.path=@{att},complain) {
  include <abstractions/attached/base>
  include <abstractions/bus-system>
  include <abstractions/attached/consoles>
  include <abstractions/attached/nameservice-strict>

  capability dac_read_search,
  capability net_admin,

  network netlink raw,

  dbus send bus=system path=/org/freedesktop/resolve1
       interface=org.freedesktop.resolve1.Manager
       member={SetLinkDNSEx,SetLinkDomains}
       peer=(name=org.freedesktop.resolve1, label="@{p_systemd_resolved}"),

  @{exec_path} mr,

  @{sh_path}                rix,
  @{bin}/cat                rix,
  @{bin}/ip                 rpx,
  @{bin}/mv                 rix,
  @{bin}/readlink           rix,
  @{bin}/resolvectl         rpx,
  @{bin}/rm                 rix,
  @{bin}/sort               rix,
  @{bin}/stat               rix,
  @{bin}/sync               rix,
  @{bin}/wg                 rpx,
  @{sbin}/nft               rix,
  @{sbin}/resolvconf        rpx,
  @{sbin}/sysctl            rcx -> sysctl,
  @{sbin}/xtables-{nft,legacy}-multi  rix,

  /usr/share/iproute2/group r,
  /usr/share/iproute2/rt_realms r,
  /usr/share/terminfo/** r,

  @{etc_rw}/wireguard/{,**} rw,
  /etc/iproute2/group  r,
  /etc/iproute2/rt_realms r,
  /etc/resolvconf/interface-order r,

  @{sys}/fs/cgroup/user.slice/cpu.max r,
  @{sys}/fs/cgroup/user.slice/user-@{uid}.slice/cpu.max r,
  @{sys}/fs/cgroup/user.slice/user-@{uid}.slice/user@@{uid}.service/cpu.max r,
  @{sys}/fs/cgroup/user.slice/user-@{uid}.slice/user@@{uid}.service/session.slice/cpu.max r,
  @{sys}/module/wireguard r,

  @{PROC}/@{pid}/cgroup r,
  @{PROC}/@{pid}/net/ip_tables_names r,

  profile sysctl flags=(attach_disconnected,attach_disconnected.path=@{att},complain) {
    include <abstractions/attached/base>

    @{sbin}/sysctl mr,

    @{PROC}/sys/net/ipv4/conf/all/src_valid_mark w,

    include if exists <local/wg-quick_sysctl>
  }

  include if exists <local/wg-quick>
}

# vim:syntax=apparmor
