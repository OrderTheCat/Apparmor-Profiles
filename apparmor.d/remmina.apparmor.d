# apparmor.d - Full set of apparmor profiles
# Copyright (C) 2023-2024 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: GPL-2.0-only

abi <abi/4.0>,

include <tunables/global>

@{exec_path} = @{bin}/remmina
@{att} = /att/remmina/
profile remmina /{,usr/}bin/remmina flags=(attach_disconnected,attach_disconnected.path=@{att},complain) {
  include <abstractions/attached/base>
  include <abstractions/audio-client>
  include <abstractions/avahi-observe>
  include <abstractions/bus/system/org.freedesktop.hostname1>
  include <abstractions/cgroup-limits>
  include <abstractions/dconf-write>
  include <abstractions/desktop>
  include <abstractions/fontconfig-cache-read>
  include <abstractions/gvfs>
  include <abstractions/ibus-strict>
  include <abstractions/attached/nameservice-strict>
  include <abstractions/network-manager-observe>
  include <abstractions/python>
  include <abstractions/secrets-service>
  include <abstractions/ssl_certs>
  include <abstractions/thumbnails-cache-read>
  include <abstractions/user-download-strict>

  network inet stream,
  network inet6 stream,
  network inet dgram,
  network inet6 dgram,
  network netlink raw,

  #aa/dbus own bus=session name=org.remmina.Remmina
  include <abstractions/bus/session/own>
  dbus bind bus=session name=org.remmina.Remmina{,.*},
  dbus receive bus=session path=/org/remmina/Remmina{,/**}
       interface=org.remmina.Remmina{,.*}
       peer=(name="@{busname}"),
  dbus send bus=session path=/org/remmina/Remmina{,/**}
       interface=org.remmina.Remmina{,.*}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Properties: reply to properties request from anyone
  dbus (send receive) bus=session path=/org/remmina/Remmina{,/**}
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Introspectable: allow clients to introspect the service
  dbus receive bus=session path=/org/remmina/Remmina{,/**}
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="@{busname}"),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus receive bus=session path=/org/remmina/Remmina{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.remmina.Remmina{,.*}}"),
  dbus send bus=session path=/org/remmina/Remmina{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.DBus}"),

  #aa/dbus talk bus=session name=org.ayatana.NotificationItem label=gnome-shell
  # Unix: allow connection to the profile
  unix type=stream peer=(label=gnome-shell),
  # org.ayatana.NotificationItem: send and receive anything to the interface on the specific peer label
  dbus (send receive) bus=session path=/org/ayatana/NotificationItem{,/**}
       interface=org.ayatana.NotificationItem{,.*}
       peer=(name="{@{busname},org.ayatana.NotificationItem{,.*},org.freedesktop.DBus}", label=gnome-shell),
  dbus send bus=session path=/org/ayatana/NotificationItem{,/**}
       interface=org.ayatana.NotificationItem{,.*}
       peer=(name="org.ayatana.NotificationItem{,.*}"),
  # DBus.Properties: read and send properties
  dbus (send receive) bus=session path=/org/ayatana/NotificationItem{,/**}
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.ayatana.NotificationItem{,.*},org.freedesktop.DBus}", label=gnome-shell),
  # DBus.Introspectable: allow service introspection
  dbus send bus=session path=/org/ayatana/NotificationItem{,/**}
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="{@{busname},org.ayatana.NotificationItem{,.*},org.freedesktop.DBus}", label=gnome-shell),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus send bus=session path=/org/ayatana/NotificationItem{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.ayatana.NotificationItem{,.*},org.freedesktop.DBus}", label=gnome-shell),
  dbus receive bus=session path=/org/ayatana/NotificationItem{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.ayatana.NotificationItem{,.*},org.freedesktop.DBus}", label=gnome-shell),


  @{exec_path} rm,

  @{python_path} rix,
  @{open_path} rpx -> child-open-browsers,
  @{bin}/lsb_release rpx,

  /usr/share/remmina/{,**} r,

  /etc/debian_version r,
  /etc/fstab r,
  /etc/lsb-release r,
  /etc/ssh/ssh_config r,
  /etc/ssh/ssh_config.d/{,*} r,
  /etc/timezone r,

  owner @{HOME}/@{XDG_SSH_DIR}/config r,
  owner @{HOME}/@{XDG_SSH_DIR}/known_hosts* r,

  owner @{user_cache_dirs}/org.remmina.Remmina/{,**} rw,
  owner @{user_cache_dirs}/remmina/{,**} rw,
  owner @{user_config_dirs}/autostart/remmina-applet.desktop r,
  owner @{user_config_dirs}/freerdp/known_hosts* rwk,
  owner @{user_config_dirs}/remmina/{,**} rw,
  owner @{user_share_dirs}/remmina/{,**} rw,

  owner @{tmp}/remmina_log_file.log rw,

  owner @{run}/user/@{uid}/keyring/ssh rw,

  @{sys}/devices/system/node/ r,
  @{sys}/devices/system/node/node@{int}/meminfo r,

  owner @{PROC}/@{pid}/task/@{tid}/comm rw,
  owner @{PROC}/@{pid}/mountinfo r,

  include if exists <local/remmina>
}

# vim:syntax=apparmor
