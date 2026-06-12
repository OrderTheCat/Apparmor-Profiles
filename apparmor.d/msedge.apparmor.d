# apparmor.d - Full set of apparmor profiles
# Copyright (C) 2022-2024 Alexandre Pujol <alexandre@pujol.io>
# Copyright (C) 2022-2024 Jose Maldonado <josemald89@gmail.com>
# SPDX-License-Identifier: GPL-2.0-only

abi <abi/4.0>,

include <tunables/global>

@{name} = msedge{,-beta,-dev}
@{domain} = com.microsoft.Edge
@{lib_dirs} = /opt/microsoft/@{name}
@{config_dirs} = @{user_config_dirs}/microsoft-edge{,-beta,-dev} @{user_config_dirs}/Microsoft/Edge
@{cache_dirs} = @{user_cache_dirs}/microsoft-edge{,-beta,-dev} @{user_cache_dirs}/Microsoft/Edge

@{exec_path} = @{lib_dirs}/@{name}
@{att} = /att/msedge/
profile msedge /opt/microsoft/msedge{,-beta,-dev}/msedge{,-beta,-dev} flags=(attach_disconnected,attach_disconnected.path=@{att},complain) {
  include <abstractions/attached/base>
  include <abstractions/app/chromium>

  #aa/dbus own bus=session name=org.mpris.MediaPlayer2.msedge path=/org/mpris/MediaPlayer2
  include <abstractions/bus/session/own>
  dbus bind bus=session name=org.mpris.MediaPlayer2.msedge{,.*},
  dbus receive bus=session path=/org/mpris/MediaPlayer2
       interface=org.mpris.MediaPlayer2.msedge{,.*}
       peer=(name="@{busname}"),
  dbus send bus=session path=/org/mpris/MediaPlayer2
       interface=org.mpris.MediaPlayer2.msedge{,.*}
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
       peer=(name="{@{busname},org.mpris.MediaPlayer2.msedge{,.*}}"),
  dbus send bus=session path=/org/mpris/MediaPlayer2
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.DBus}"),


  @{exec_path} mrix,

  @{bin}/man  rpux, #  For "chrome --help"

  @{lib_dirs}/msedge_crashpad_handler  px -> msedge//&msedge//crashpad_handler,
  @{lib_dirs}/microsoft-edge{,beta,-dev} ix,

  @{lib_dirs}/WidevineCdm/_platform_specific/linux_*/libwidevinecdm.so mr,

  owner @{user_cache_dirs}/Microsoft/ rw,

  owner @{tmp}/.ses rw,
  owner @{tmp}/cv_debug.log rw,

  include if exists <local/msedge>
}

# vim:syntax=apparmor
