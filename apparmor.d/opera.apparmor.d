# apparmor.d - Full set of apparmor profiles
# Copyright (C) 2018-2021 Mikhail Morfikov
# Copyright (C) 2021-2024 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: GPL-2.0-only

abi <abi/4.0>,

include <tunables/global>

@{name} = opera{,-beta,-developer}
@{domain} = com.opera.Opera
@{lib_dirs} = @{lib}/@{multiarch}/@{name}
@{config_dirs} = @{user_config_dirs}/@{name}
@{cache_dirs} = @{user_cache_dirs}/@{name}

@{exec_path} = @{lib_dirs}/@{name}
@{att} = /att/opera/
profile opera /{,usr/}lib{,exec,32,64}/*-linux-gnu*/opera{,-beta,-developer}/opera{,-beta,-developer} flags=(attach_disconnected,attach_disconnected.path=@{att},complain) {
  include <abstractions/attached/base>
  include <abstractions/app/chromium>

  #aa/dbus own bus=session name=org.mpris.MediaPlayer2.opera path=/org/mpris/MediaPlayer2
  include <abstractions/bus/session/own>
  dbus bind bus=session name=org.mpris.MediaPlayer2.opera{,.*},
  dbus receive bus=session path=/org/mpris/MediaPlayer2
       interface=org.mpris.MediaPlayer2.opera{,.*}
       peer=(name="@{busname}"),
  dbus send bus=session path=/org/mpris/MediaPlayer2
       interface=org.mpris.MediaPlayer2.opera{,.*}
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
       peer=(name="{@{busname},org.mpris.MediaPlayer2.opera{,.*}}"),
  dbus send bus=session path=/org/mpris/MediaPlayer2
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.DBus}"),


  @{exec_path} mrix,

  @{lib_dirs}/opera_autoupdate    krix,
  @{lib_dirs}/opera_crashreporter  rpx,
  @{lib_dirs}/opera-sandbox        rpx,

  /opt/google/chrome{,-beta,-unstable}/libwidevinecdm.so mr,
  /opt/google/chrome{,-beta,-unstable}/libwidevinecdmadapter.so mr,

  include if exists <local/opera>
}

# vim:syntax=apparmor
