# apparmor.d - Full set of apparmor profiles
# Copyright (C) 2023-2024 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: GPL-2.0-only

abi <abi/4.0>,

include <tunables/global>

@{exec_path} = @{bin}/transmission-{gtk,qt}
@{att} = /att/transmission/
profile transmission /{,usr/}bin/transmission-{gtk,qt} flags=(attach_disconnected,attach_disconnected.path=@{att},complain) {
  include <abstractions/attached/base>
  include <abstractions/bus/session/org.gtk.Private.RemoteVolumeMonitor>
  include <abstractions/bus/system/org.freedesktop.hostname1>
  include <abstractions/dconf-write>
  include <abstractions/desktop>
  include <abstractions/graphics>
  include <abstractions/gvfs>
  include <abstractions/attached/nameservice-strict>
  include <abstractions/screen-inhibit>
  include <abstractions/ssl_certs>
  include <abstractions/trash-strict>
  include <abstractions/user-download-strict>

  network inet dgram,
  network inet6 dgram,
  network inet stream,
  network inet6 stream,
  network netlink raw,

  #aa/dbus own bus=session name=com.transmissionbt.Transmission
  include <abstractions/bus/session/own>
  dbus bind bus=session name=com.transmissionbt.Transmission{,.*},
  dbus receive bus=session path=/com/transmissionbt/Transmission{,/**}
       interface=com.transmissionbt.Transmission{,.*}
       peer=(name="@{busname}"),
  dbus send bus=session path=/com/transmissionbt/Transmission{,/**}
       interface=com.transmissionbt.Transmission{,.*}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Properties: reply to properties request from anyone
  dbus (send receive) bus=session path=/com/transmissionbt/Transmission{,/**}
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Introspectable: allow clients to introspect the service
  dbus receive bus=session path=/com/transmissionbt/Transmission{,/**}
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="@{busname}"),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus receive bus=session path=/com/transmissionbt/Transmission{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},com.transmissionbt.Transmission{,.*}}"),
  dbus send bus=session path=/com/transmissionbt/Transmission{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.DBus}"),

  #aa/dbus own bus=session name=com.transmissionbt.transmission_*
  dbus bind bus=session name=com.transmissionbt.transmission_*{,.*},
  dbus receive bus=session path=/com/transmissionbt/transmission_*{,/**}
       interface=com.transmissionbt.transmission_*{,.*}
       peer=(name="@{busname}"),
  dbus send bus=session path=/com/transmissionbt/transmission_*{,/**}
       interface=com.transmissionbt.transmission_*{,.*}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Properties: reply to properties request from anyone
  dbus (send receive) bus=session path=/com/transmissionbt/transmission_*{,/**}
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Introspectable: allow clients to introspect the service
  dbus receive bus=session path=/com/transmissionbt/transmission_*{,/**}
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="@{busname}"),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus receive bus=session path=/com/transmissionbt/transmission_*{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},com.transmissionbt.transmission_*{,.*}}"),
  dbus send bus=session path=/com/transmissionbt/transmission_*{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.DBus}"),


  @{exec_path} mr,

  @{open_path}         rpx -> child-open,

  /usr/share/transmission/{,**} r,

  owner @{HOME}/ r,

  owner @{user_torrents_dirs}/ r,
  owner @{user_torrents_dirs}/** rw,

  owner @{user_config_dirs}/transmission/ rw,
  owner @{user_config_dirs}/transmission/** rwk,

  owner @{user_cache_dirs}/transmission/ rw,
  owner @{user_cache_dirs}/transmission/** rwk,

  owner @{tmp}/tr_session_id_* rwk,

  @{run}/mount/utab r,

        @{PROC}/@{pid}/net/route r,
        @{PROC}/sys/net/ipv6/conf/all/disable_ipv6 r,
  owner @{PROC}/@{pid}/cmdline r,
  owner @{PROC}/@{pid}/comm r,
  owner @{PROC}/@{pid}/mountinfo r,
  owner @{PROC}/@{pid}/mounts r,
  owner @{PROC}/@{pid}/stat r,
  owner @{PROC}/@{pid}/task/@{tid}/comm rw,

  include if exists <local/transmission>
}

# vim:syntax=apparmor
