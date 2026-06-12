# apparmor.d - Full set of apparmor profiles
# Copyright (C) 2019-2021 Mikhail Morfikov
# Copyright (C) 2021-2024 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: GPL-2.0-only

abi <abi/4.0>,

include <tunables/global>

@{name} = brave{,-beta,-dev,-bin}
@{domain} = com.brave.Brave org.chromium.Chromium
@{lib_dirs} = /opt/brave{-bin,.com}{,/@{name}}
@{config_dirs} = @{user_config_dirs}/BraveSoftware/
@{cache_dirs} = @{user_cache_dirs}/BraveSoftware/

@{exec_path} = @{lib_dirs}/@{name}
@{att} = /att/brave/
profile brave /opt/brave{-bin,.com}{,/brave{,-beta,-dev,-bin}}/brave{,-beta,-dev,-bin} flags=(attach_disconnected,attach_disconnected.path=@{att},complain) {
  include <abstractions/attached/base>
  include <abstractions/app/chromium>

  #aa/dbus own bus=session name=org.mpris.MediaPlayer2.brave path=/org/mpris/MediaPlayer2
  include <abstractions/bus/session/own>
  dbus bind bus=session name=org.mpris.MediaPlayer2.brave{,.*},
  dbus receive bus=session path=/org/mpris/MediaPlayer2
       interface=org.mpris.MediaPlayer2.brave{,.*}
       peer=(name="@{busname}"),
  dbus send bus=session path=/org/mpris/MediaPlayer2
       interface=org.mpris.MediaPlayer2.brave{,.*}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Properties: reply to properties request from anyone
  dbus (send receive) bus=session path=/org/mpris/MediaPlayer2
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Introspectable: allow clients to introspect the service
  dbus receive bus=session path=/org/mpris/MediaPlayer2
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="@{busname}"),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus receive bus=session path=/org/mpris/MediaPlayer2
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.mpris.MediaPlayer2.brave{,.*}}"),
  dbus send bus=session path=/org/mpris/MediaPlayer2
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.DBus}"),


  ptrace trace peer=brave,

  @{exec_path} mrix,

  @{bin}/man  rpux, #  For "brave --help"

  @{lib_dirs}/chrome_crashpad_handler  px -> brave//&brave//crashpad_handler,

  /usr/share/chromium/extensions/ r,

  /etc/opt/chrome/ r,
  /etc/opt/chrome/native-messaging-hosts/* r,

  owner @{config_dirs}/WidevineCdm/libwidevinecdm.so mrw,

  owner @{tmp}/net-export/ rw,  # For brave://net-export/

  # Silencer
  deny /etc/opt/ w,
  deny /etc/opt/chrome/ w,
  deny /dev/disk/by-uuid/ r,

  include if exists <local/brave>
}

# vim:syntax=apparmor
