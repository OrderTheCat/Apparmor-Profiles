# apparmor.d - Full set of apparmor profiles
# Copyright (C) 2024 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: GPL-2.0-only

abi <abi/4.0>,

include <tunables/global>

@{exec_path} = @{bin}/foliate
@{att} = /att/foliate/
profile foliate /{,usr/}bin/foliate flags=(attach_disconnected,attach_disconnected.path=@{att},complain) {
  include <abstractions/attached/base>
  include <abstractions/app/bwrap-glycin>
  include <abstractions/common/gnome>
  include <abstractions/attached/nameservice-strict>
  include <abstractions/p11-kit>
  include <abstractions/ssl_certs>
  include <abstractions/user-download-strict>
  include <abstractions/webkit>

  capability dac_override,

  network inet dgram,
  network inet6 dgram,
  network inet stream,
  network inet6 stream,
  network netlink raw,

  #aa/dbus own bus=session name=com.github.johnfactotum.Foliate
  include <abstractions/bus/session/own>
  dbus bind bus=session name=com.github.johnfactotum.Foliate{,.*},
  dbus receive bus=session path=/com/github/johnfactotum/Foliate{,/**}
       interface=com.github.johnfactotum.Foliate{,.*}
       peer=(name="@{busname}"),
  dbus send bus=session path=/com/github/johnfactotum/Foliate{,/**}
       interface=com.github.johnfactotum.Foliate{,.*}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Properties: reply to properties request from anyone
  dbus (send receive) bus=session path=/com/github/johnfactotum/Foliate{,/**}
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Introspectable: allow clients to introspect the service
  dbus receive bus=session path=/com/github/johnfactotum/Foliate{,/**}
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="@{busname}"),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus receive bus=session path=/com/github/johnfactotum/Foliate{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},com.github.johnfactotum.Foliate{,.*}}"),
  dbus send bus=session path=/com/github/johnfactotum/Foliate{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.DBus}"),


  @{exec_path} mr,

  @{bin}/bwrap             rix,
  @{bin}/gjs-console       rix,
  @{bin}/speech-dispatcher  px,
  @{open_path}              px -> child-open-help,


  @{lib}/glycin-loaders/@{d}+/glycin-* cx -> foliate//&glycin//loaders,

  /usr/share/com.github.johnfactotum.Foliate/{,**} r,

  owner @{user_books_dirs}/{,**} r,
  owner @{user_torrents_dirs}/{,**} r,

  owner @{user_cache_dirs}/com.github.johnfactotum.Foliate/{,**} rwlk,
  owner @{user_share_dirs}/com.github.johnfactotum.Foliate/{,**} rwlk,

  @{sys}/fs/cgroup/user.slice/user-@{uid}.slice/user@@{uid}.service/app.slice/app-dbus*org.gnome.Nautilus.slice/dbus*org.gnome.Nautilus@*.service/memory.* r,
  @{sys}/fs/cgroup/user.slice/user-@{uid}.slice/user@@{uid}.service/app.slice/app-gnome-com.github.johnfactotum.Foliate-@{int}.scope/memory.* r,

        @{PROC}/sys/net/ipv6/conf/all/disable_ipv6 r,
        @{PROC}/zoneinfo r,
  owner @{PROC}/@{pid}/cgroup r,
  owner @{PROC}/@{pid}/mounts r,
  owner @{PROC}/@{pid}/smaps r,
  owner @{PROC}/@{pid}/statm r,
  owner @{PROC}/@{pid}/task/@{tid}/stat r,

  deny @{user_share_dirs}/gvfs-metadata/* r,

  include if exists <local/foliate>
}

# vim:syntax=apparmor
