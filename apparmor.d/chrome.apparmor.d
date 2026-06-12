# apparmor.d - Full set of apparmor profiles
# Copyright (C) 2018-2021 Mikhail Morfikov
# Copyright (C) 2022-2024 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: GPL-2.0-only

abi <abi/4.0>,

include <tunables/global>

@{name} = chrome{,-beta,-stable,-unstable}
@{domain} = com.google.Chrome
@{lib_dirs} = /opt/google/@{name}
@{config_dirs} = @{user_config_dirs}/google-@{name}
@{cache_dirs} = @{user_cache_dirs}/google-@{name}

@{exec_path} = @{lib_dirs}/@{name}
@{att} = /att/chrome/
profile chrome /opt/google/chrome{,-beta,-stable,-unstable}/chrome{,-beta,-stable,-unstable} flags=(attach_disconnected,attach_disconnected.path=@{att},complain) {
  include <abstractions/attached/base>
  include <abstractions/app/chromium>

  #aa/dbus own bus=session name=org.mpris.MediaPlayer2.chrome path=/org/mpris/MediaPlayer2
  include <abstractions/bus/session/own>
  dbus bind bus=session name=org.mpris.MediaPlayer2.chrome{,.*},
  dbus receive bus=session path=/org/mpris/MediaPlayer2
       interface=org.mpris.MediaPlayer2.chrome{,.*}
       peer=(name="@{busname}"),
  dbus send bus=session path=/org/mpris/MediaPlayer2
       interface=org.mpris.MediaPlayer2.chrome{,.*}
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
       peer=(name="{@{busname},org.mpris.MediaPlayer2.chrome{,.*}}"),
  dbus send bus=session path=/org/mpris/MediaPlayer2
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.DBus}"),


  @{exec_path} mrix,

  @{bin}/man  rpux, #  For "chrome --help"

  @{lib_dirs}/chrome_crashpad_handler  px -> chrome//&chrome//crashpad_handler,
  @{lib_dirs}/google-@{name}           px,

  include if exists <local/chrome>
}

# vim:syntax=apparmor
