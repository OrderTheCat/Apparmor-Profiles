# apparmor.d - Full set of apparmor profiles
# Copyright (C) 2018-2022 Mikhail Morfikov
# Copyright (C) 2022-2024 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: GPL-2.0-only

abi <abi/4.0>,

include <tunables/global>

@{name} = chromium
@{domain} = org.chromium.Chromium
@{lib_dirs} = @{lib}/@{name}
@{config_dirs} = @{user_config_dirs}/@{name}
@{cache_dirs} = @{user_cache_dirs}/@{name}

@{exec_path} = @{lib_dirs}/@{name}
@{att} = /att/chromium/
profile chromium /{,usr/}lib{,exec,32,64}/chromium/chromium flags=(attach_disconnected,attach_disconnected.path=@{att},complain) {
  include <abstractions/attached/base>
  include <abstractions/app/chromium>

  #aa/dbus own bus=session name=org.mpris.MediaPlayer2.chromium path=/org/mpris/MediaPlayer2
  include <abstractions/bus/session/own>
  dbus bind bus=session name=org.mpris.MediaPlayer2.chromium{,.*},
  dbus receive bus=session path=/org/mpris/MediaPlayer2
       interface=org.mpris.MediaPlayer2.chromium{,.*}
       peer=(name="@{busname}"),
  dbus send bus=session path=/org/mpris/MediaPlayer2
       interface=org.mpris.MediaPlayer2.chromium{,.*}
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
       peer=(name="{@{busname},org.mpris.MediaPlayer2.chromium{,.*}}"),
  dbus send bus=session path=/org/mpris/MediaPlayer2
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.DBus}"),


  @{exec_path} mrix,

  @{lib_dirs}/chrome_crashpad_handler  px -> chromium//&chromium//crashpad_handler,

  include if exists <local/chromium>
}

# vim:syntax=apparmor
