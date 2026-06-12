# apparmor.d - Full set of apparmor profiles
# Copyright (C) 2024 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: GPL-2.0-only

abi <abi/4.0>,

include <tunables/global>

@{exec_path} = @{bin}/loupe
@{att} = /att/loupe/
profile loupe /{,usr/}bin/loupe flags=(attach_disconnected,attach_disconnected.path=@{att},complain) {
  include <abstractions/attached/base>
  include <abstractions/bus/system/org.freedesktop.hostname1>
  include <abstractions/dconf-write>
  include <abstractions/gnome-strict>
  include <abstractions/graphics>
  include <abstractions/attached/nameservice-strict>
  include <abstractions/thumbnails-cache-write>
  include <abstractions/trash-strict>
  include <abstractions/user-read-strict>
  include <abstractions/user-write-strict>

  #aa/dbus own bus=session name=org.gnome.Loupe
  include <abstractions/bus/session/own>
  dbus bind bus=session name=org.gnome.Loupe{,.*},
  dbus receive bus=session path=/org/gnome/Loupe{,/**}
       interface=org.gnome.Loupe{,.*}
       peer=(name="@{busname}"),
  dbus send bus=session path=/org/gnome/Loupe{,/**}
       interface=org.gnome.Loupe{,.*}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Properties: reply to properties request from anyone
  dbus (send receive) bus=session path=/org/gnome/Loupe{,/**}
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Introspectable: allow clients to introspect the service
  dbus receive bus=session path=/org/gnome/Loupe{,/**}
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="@{busname}"),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus receive bus=session path=/org/gnome/Loupe{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.gnome.Loupe{,.*}}"),
  dbus send bus=session path=/org/gnome/Loupe{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.DBus}"),


  #aa/dbus talk bus=session name=org.gtk.vfs label="gvfsd{,-*}"
  # Unix: allow connection to the profile
  unix type=stream peer=(label="gvfsd{,-*}"),
  # org.gtk.vfs: send and receive anything to the interface on the specific peer label
  dbus (send receive) bus=session path=/org/gtk/vfs{,/**}
       interface=org.gtk.vfs{,.*}
       peer=(name="{@{busname},org.gtk.vfs{,.*},org.freedesktop.DBus}", label="gvfsd{,-*}"),
  dbus send bus=session path=/org/gtk/vfs{,/**}
       interface=org.gtk.vfs{,.*}
       peer=(name="org.gtk.vfs{,.*}"),
  # DBus.Properties: read and send properties
  dbus (send receive) bus=session path=/org/gtk/vfs{,/**}
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.gtk.vfs{,.*},org.freedesktop.DBus}", label="gvfsd{,-*}"),
  # DBus.Introspectable: allow service introspection
  dbus send bus=session path=/org/gtk/vfs{,/**}
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="{@{busname},org.gtk.vfs{,.*},org.freedesktop.DBus}", label="gvfsd{,-*}"),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus send bus=session path=/org/gtk/vfs{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.gtk.vfs{,.*},org.freedesktop.DBus}", label="gvfsd{,-*}"),
  dbus receive bus=session path=/org/gtk/vfs{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.gtk.vfs{,.*},org.freedesktop.DBus}", label="gvfsd{,-*}"),


  @{exec_path} mr,

  @{open_path} rpx -> child-open-help,

  / r,

        @{run}/mount/utab r,
  owner @{run}/user/@{uid}/gvfsd/socket-@{rand8} rw,

        @{sys}/fs/cgroup/user.slice/cpu.max r,
        @{sys}/fs/cgroup/user.slice/user-@{uid}.slice/cpu.max r,
        @{sys}/fs/cgroup/user.slice/user-@{uid}.slice/user@@{uid}.service/app.slice/cpu.max r,
        @{sys}/fs/cgroup/user.slice/user-@{uid}.slice/user@@{uid}.service/cpu.max r,
  owner @{sys}/fs/cgroup/user.slice/user-@{uid}.slice/user@@{uid}.service/session.slice/cpu.max r,

  owner @{PROC}/@{pid}/cgroup r,
  owner @{PROC}/@{pid}/cmdline r,
  owner @{PROC}/@{pid}/mountinfo r,
  owner @{PROC}/@{pid}/stat r,
  owner @{PROC}/@{pid}/task/@{tid}/comm rw,

  deny @{user_share_dirs}/gvfs-metadata/* r,

  include if exists <local/loupe>
}

# vim:syntax=apparmor
