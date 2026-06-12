# apparmor.d - Full set of apparmor profiles
# Copyright (C) 2023-2024 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: GPL-2.0-only

abi <abi/4.0>,

include <tunables/global>

@{exec_path} = @{bin}/plasmashell
@{att} = /att/plasmashell/
profile plasmashell /{,usr/}bin/plasmashell flags=(attach_disconnected,attach_disconnected.path=@{att},mediate_deleted,complain) {
  include <abstractions/attached/base>
  include <abstractions/app-launcher-user>
  include <abstractions/audio-client>
  include <abstractions/bus-session>
  include <abstractions/bus/system/org.freedesktop.login1>
  include <abstractions/bus/system/org.freedesktop.UDisks2>
  include <abstractions/attached/consoles>
  include <abstractions/cups-client>
  include <abstractions/devices-usb>
  include <abstractions/disks-read>
  include <abstractions/enchant>
  include <abstractions/graphics>
  include <abstractions/kde-strict>
  include <abstractions/attached/nameservice-strict>
  include <abstractions/qt5-shader-cache>
  include <abstractions/recent-documents-write>
  include <abstractions/ssl_certs>
  include <abstractions/sys/dmi>
  include <abstractions/thumbnails-cache-write>
  include <abstractions/upower-observe>

  userns,

  capability sys_ptrace,

  network inet dgram,
  network inet6 dgram,
  network inet stream,
  network inet6 stream,
  network netlink dgram,
  network netlink raw,

  ptrace read,

  signal send,

  # Owned by plasmashell

  #aa/dbus own bus=session name=com.canonical.Unity
  include <abstractions/bus/session/own>
  dbus bind bus=session name=com.canonical.Unity{,.*},
  dbus receive bus=session path=/com/canonical/Unity{,/**}
       interface=com.canonical.Unity{,.*}
       peer=(name="@{busname}"),
  dbus send bus=session path=/com/canonical/Unity{,/**}
       interface=com.canonical.Unity{,.*}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Properties: reply to properties request from anyone
  dbus (send receive) bus=session path=/com/canonical/Unity{,/**}
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Introspectable: allow clients to introspect the service
  dbus receive bus=session path=/com/canonical/Unity{,/**}
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="@{busname}"),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus receive bus=session path=/com/canonical/Unity{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},com.canonical.Unity{,.*}}"),
  dbus send bus=session path=/com/canonical/Unity{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.DBus}"),

  #aa/dbus own bus=session name=org.freedesktop.Notifications
  dbus bind bus=session name=org.freedesktop.Notifications{,.*},
  dbus receive bus=session path=/org/freedesktop/Notifications{,/**}
       interface=org.freedesktop.Notifications{,.*}
       peer=(name="@{busname}"),
  dbus send bus=session path=/org/freedesktop/Notifications{,/**}
       interface=org.freedesktop.Notifications{,.*}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Properties: reply to properties request from anyone
  dbus (send receive) bus=session path=/org/freedesktop/Notifications{,/**}
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Introspectable: allow clients to introspect the service
  dbus receive bus=session path=/org/freedesktop/Notifications{,/**}
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="@{busname}"),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus receive bus=session path=/org/freedesktop/Notifications{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.freedesktop.Notifications{,.*}}"),
  dbus send bus=session path=/org/freedesktop/Notifications{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.DBus}"),

  #aa/dbus own bus=session name=org.kde.JobViewServer
  dbus bind bus=session name=org.kde.JobViewServer{,.*},
  dbus receive bus=session path=/org/kde/JobViewServer{,/**}
       interface=org.kde.JobViewServer{,.*}
       peer=(name="@{busname}"),
  dbus send bus=session path=/org/kde/JobViewServer{,/**}
       interface=org.kde.JobViewServer{,.*}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Properties: reply to properties request from anyone
  dbus (send receive) bus=session path=/org/kde/JobViewServer{,/**}
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Introspectable: allow clients to introspect the service
  dbus receive bus=session path=/org/kde/JobViewServer{,/**}
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="@{busname}"),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus receive bus=session path=/org/kde/JobViewServer{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.kde.JobViewServer{,.*}}"),
  dbus send bus=session path=/org/kde/JobViewServer{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.DBus}"),

  #aa/dbus own bus=session name=org.kde.klipper
  dbus bind bus=session name=org.kde.klipper{,.*},
  dbus receive bus=session path=/org/kde/klipper{,/**}
       interface=org.kde.klipper{,.*}
       peer=(name="@{busname}"),
  dbus send bus=session path=/org/kde/klipper{,/**}
       interface=org.kde.klipper{,.*}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Properties: reply to properties request from anyone
  dbus (send receive) bus=session path=/org/kde/klipper{,/**}
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Introspectable: allow clients to introspect the service
  dbus receive bus=session path=/org/kde/klipper{,/**}
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="@{busname}"),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus receive bus=session path=/org/kde/klipper{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.kde.klipper{,.*}}"),
  dbus send bus=session path=/org/kde/klipper{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.DBus}"),

  #aa/dbus own bus=session name=org.kde.kuiserver
  dbus bind bus=session name=org.kde.kuiserver{,.*},
  dbus receive bus=session path=/org/kde/kuiserver{,/**}
       interface=org.kde.kuiserver{,.*}
       peer=(name="@{busname}"),
  dbus send bus=session path=/org/kde/kuiserver{,/**}
       interface=org.kde.kuiserver{,.*}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Properties: reply to properties request from anyone
  dbus (send receive) bus=session path=/org/kde/kuiserver{,/**}
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Introspectable: allow clients to introspect the service
  dbus receive bus=session path=/org/kde/kuiserver{,/**}
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="@{busname}"),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus receive bus=session path=/org/kde/kuiserver{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.kde.kuiserver{,.*}}"),
  dbus send bus=session path=/org/kde/kuiserver{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.DBus}"),

  #aa/dbus own bus=session name=org.kde.plasmashell path=/PlasmaShell
  dbus bind bus=session name=org.kde.plasmashell{,.*},
  dbus receive bus=session path=/PlasmaShell
       interface=org.kde.plasmashell{,.*}
       peer=(name="@{busname}"),
  dbus send bus=session path=/PlasmaShell
       interface=org.kde.plasmashell{,.*}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Properties: reply to properties request from anyone
  dbus (send receive) bus=session path=/PlasmaShell
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Introspectable: allow clients to introspect the service
  dbus receive bus=session path=/PlasmaShell
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="@{busname}"),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus receive bus=session path=/PlasmaShell
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.kde.plasmashell{,.*}}"),
  dbus send bus=session path=/PlasmaShell
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.DBus}"),

  #aa/dbus own bus=session name=org.kde.StatusNotifierHost-@{int}
  dbus bind bus=session name=org.kde.StatusNotifierHost-@{int}{,.*},
  dbus receive bus=session path=/org/kde/StatusNotifierHost-@{int}{,/**}
       interface=org.kde.StatusNotifierHost-@{int}{,.*}
       peer=(name="@{busname}"),
  dbus send bus=session path=/org/kde/StatusNotifierHost-@{int}{,/**}
       interface=org.kde.StatusNotifierHost-@{int}{,.*}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Properties: reply to properties request from anyone
  dbus (send receive) bus=session path=/org/kde/StatusNotifierHost-@{int}{,/**}
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Introspectable: allow clients to introspect the service
  dbus receive bus=session path=/org/kde/StatusNotifierHost-@{int}{,/**}
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="@{busname}"),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus receive bus=session path=/org/kde/StatusNotifierHost-@{int}{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.kde.StatusNotifierHost-@{int}{,.*}}"),
  dbus send bus=session path=/org/kde/StatusNotifierHost-@{int}{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.DBus}"),


  # Talk with plasmashell

  #aa/dbus talk bus=system name=org.freedesktop.NetworkManager label=NetworkManager
  # Unix: allow connection to the profile
  unix type=stream peer=(label=NetworkManager),
  # org.freedesktop.NetworkManager: send and receive anything to the interface on the specific peer label
  dbus (send receive) bus=system path=/org/freedesktop/NetworkManager{,/**}
       interface=org.freedesktop.NetworkManager{,.*}
       peer=(name="{@{busname},org.freedesktop.NetworkManager{,.*},org.freedesktop.DBus}", label=NetworkManager),
  dbus send bus=system path=/org/freedesktop/NetworkManager{,/**}
       interface=org.freedesktop.NetworkManager{,.*}
       peer=(name="org.freedesktop.NetworkManager{,.*}"),
  # DBus.Properties: read and send properties
  dbus (send receive) bus=system path=/org/freedesktop/NetworkManager{,/**}
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.freedesktop.NetworkManager{,.*},org.freedesktop.DBus}", label=NetworkManager),
  # DBus.Introspectable: allow service introspection
  dbus send bus=system path=/org/freedesktop/NetworkManager{,/**}
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="{@{busname},org.freedesktop.NetworkManager{,.*},org.freedesktop.DBus}", label=NetworkManager),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus send bus=system path=/org/freedesktop/NetworkManager{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.freedesktop.NetworkManager{,.*},org.freedesktop.DBus}", label=NetworkManager),
  dbus receive bus=system path=/org/freedesktop/NetworkManager{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.NetworkManager{,.*},org.freedesktop.DBus}", label=NetworkManager),


  #aa/dbus talk bus=session name=org.kde.kdeconnect path=/ label=kdeconnectd
  # Unix: allow connection to the profile
  unix type=stream peer=(label=kdeconnectd),
  # org.kde.kdeconnect: send and receive anything to the interface on the specific peer label
  dbus (send receive) bus=session path=/
       interface=org.kde.kdeconnect{,.*}
       peer=(name="{@{busname},org.kde.kdeconnect{,.*},org.freedesktop.DBus}", label=kdeconnectd),
  dbus send bus=session path=/
       interface=org.kde.kdeconnect{,.*}
       peer=(name="org.kde.kdeconnect{,.*}"),
  # DBus.Properties: read and send properties
  dbus (send receive) bus=session path=/
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.kde.kdeconnect{,.*},org.freedesktop.DBus}", label=kdeconnectd),
  # DBus.Introspectable: allow service introspection
  dbus send bus=session path=/
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="{@{busname},org.kde.kdeconnect{,.*},org.freedesktop.DBus}", label=kdeconnectd),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus send bus=session path=/
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.kde.kdeconnect{,.*},org.freedesktop.DBus}", label=kdeconnectd),
  dbus receive bus=session path=/
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.kde.kdeconnect{,.*},org.freedesktop.DBus}", label=kdeconnectd),

  #aa/dbus talk bus=session name=org.kde.KeyboardLayouts path=/Layouts label=kded
  # Unix: allow connection to the profile
  unix type=stream peer=(label=kded),
  # org.kde.KeyboardLayouts: send and receive anything to the interface on the specific peer label
  dbus (send receive) bus=session path=/Layouts
       interface=org.kde.KeyboardLayouts{,.*}
       peer=(name="{@{busname},org.kde.KeyboardLayouts{,.*},org.freedesktop.DBus}", label=kded),
  dbus send bus=session path=/Layouts
       interface=org.kde.KeyboardLayouts{,.*}
       peer=(name="org.kde.KeyboardLayouts{,.*}"),
  # DBus.Properties: read and send properties
  dbus (send receive) bus=session path=/Layouts
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.kde.KeyboardLayouts{,.*},org.freedesktop.DBus}", label=kded),
  # DBus.Introspectable: allow service introspection
  dbus send bus=session path=/Layouts
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="{@{busname},org.kde.KeyboardLayouts{,.*},org.freedesktop.DBus}", label=kded),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus send bus=session path=/Layouts
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.kde.KeyboardLayouts{,.*},org.freedesktop.DBus}", label=kded),
  dbus receive bus=session path=/Layouts
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.kde.KeyboardLayouts{,.*},org.freedesktop.DBus}", label=kded),

  #aa/dbus talk bus=session name=org.kde.KGlobalAccel path=/kglobalaccel label="{kglobalacceld,kwin_wayland}"
  # Unix: allow connection to the profile
  unix type=stream peer=(label="{kglobalacceld,kwin_wayland}"),
  # org.kde.KGlobalAccel: send and receive anything to the interface on the specific peer label
  dbus (send receive) bus=session path=/kglobalaccel
       interface=org.kde.KGlobalAccel{,.*}
       peer=(name="{@{busname},org.kde.KGlobalAccel{,.*},org.freedesktop.DBus}", label="{kglobalacceld,kwin_wayland}"),
  dbus send bus=session path=/kglobalaccel
       interface=org.kde.KGlobalAccel{,.*}
       peer=(name="org.kde.KGlobalAccel{,.*}"),
  # DBus.Properties: read and send properties
  dbus (send receive) bus=session path=/kglobalaccel
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.kde.KGlobalAccel{,.*},org.freedesktop.DBus}", label="{kglobalacceld,kwin_wayland}"),
  # DBus.Introspectable: allow service introspection
  dbus send bus=session path=/kglobalaccel
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="{@{busname},org.kde.KGlobalAccel{,.*},org.freedesktop.DBus}", label="{kglobalacceld,kwin_wayland}"),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus send bus=session path=/kglobalaccel
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.kde.KGlobalAccel{,.*},org.freedesktop.DBus}", label="{kglobalacceld,kwin_wayland}"),
  dbus receive bus=session path=/kglobalaccel
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.kde.KGlobalAccel{,.*},org.freedesktop.DBus}", label="{kglobalacceld,kwin_wayland}"),

  #aa/dbus talk bus=session name=org.kde.KSplash path=/KSplash label=ksplashqml
  # Unix: allow connection to the profile
  unix type=stream peer=(label=ksplashqml),
  # org.kde.KSplash: send and receive anything to the interface on the specific peer label
  dbus (send receive) bus=session path=/KSplash
       interface=org.kde.KSplash{,.*}
       peer=(name="{@{busname},org.kde.KSplash{,.*},org.freedesktop.DBus}", label=ksplashqml),
  dbus send bus=session path=/KSplash
       interface=org.kde.KSplash{,.*}
       peer=(name="org.kde.KSplash{,.*}"),
  # DBus.Properties: read and send properties
  dbus (send receive) bus=session path=/KSplash
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.kde.KSplash{,.*},org.freedesktop.DBus}", label=ksplashqml),
  # DBus.Introspectable: allow service introspection
  dbus send bus=session path=/KSplash
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="{@{busname},org.kde.KSplash{,.*},org.freedesktop.DBus}", label=ksplashqml),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus send bus=session path=/KSplash
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.kde.KSplash{,.*},org.freedesktop.DBus}", label=ksplashqml),
  dbus receive bus=session path=/KSplash
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.kde.KSplash{,.*},org.freedesktop.DBus}", label=ksplashqml),

  #aa/dbus talk bus=session name=org.kde.KWin path=/ label="kwin_{wayland,x11}"
  # Unix: allow connection to the profile
  unix type=stream peer=(label="kwin_{wayland,x11}"),
  # org.kde.KWin: send and receive anything to the interface on the specific peer label
  dbus (send receive) bus=session path=/
       interface=org.kde.KWin{,.*}
       peer=(name="{@{busname},org.kde.KWin{,.*},org.freedesktop.DBus}", label="kwin_{wayland,x11}"),
  dbus send bus=session path=/
       interface=org.kde.KWin{,.*}
       peer=(name="org.kde.KWin{,.*}"),
  # DBus.Properties: read and send properties
  dbus (send receive) bus=session path=/
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.kde.KWin{,.*},org.freedesktop.DBus}", label="kwin_{wayland,x11}"),
  # DBus.Introspectable: allow service introspection
  dbus send bus=session path=/
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="{@{busname},org.kde.KWin{,.*},org.freedesktop.DBus}", label="kwin_{wayland,x11}"),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus send bus=session path=/
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.kde.KWin{,.*},org.freedesktop.DBus}", label="kwin_{wayland,x11}"),
  dbus receive bus=session path=/
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.kde.KWin{,.*},org.freedesktop.DBus}", label="kwin_{wayland,x11}"),

  #aa/dbus talk bus=session name=org.kde.NightColor path=/ColorCorrect label="kwin_{wayland,x11}"
  # Unix: allow connection to the profile
  unix type=stream peer=(label="kwin_{wayland,x11}"),
  # org.kde.NightColor: send and receive anything to the interface on the specific peer label
  dbus (send receive) bus=session path=/ColorCorrect
       interface=org.kde.NightColor{,.*}
       peer=(name="{@{busname},org.kde.NightColor{,.*},org.freedesktop.DBus}", label="kwin_{wayland,x11}"),
  dbus send bus=session path=/ColorCorrect
       interface=org.kde.NightColor{,.*}
       peer=(name="org.kde.NightColor{,.*}"),
  # DBus.Properties: read and send properties
  dbus (send receive) bus=session path=/ColorCorrect
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.kde.NightColor{,.*},org.freedesktop.DBus}", label="kwin_{wayland,x11}"),
  # DBus.Introspectable: allow service introspection
  dbus send bus=session path=/ColorCorrect
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="{@{busname},org.kde.NightColor{,.*},org.freedesktop.DBus}", label="kwin_{wayland,x11}"),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus send bus=session path=/ColorCorrect
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.kde.NightColor{,.*},org.freedesktop.DBus}", label="kwin_{wayland,x11}"),
  dbus receive bus=session path=/ColorCorrect
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.kde.NightColor{,.*},org.freedesktop.DBus}", label="kwin_{wayland,x11}"),

  #aa/dbus talk bus=session name=org.kde.Solid.PowerManagement label=kde-powerdevil
  # Unix: allow connection to the profile
  unix type=stream peer=(label=kde-powerdevil),
  # org.kde.Solid.PowerManagement: send and receive anything to the interface on the specific peer label
  dbus (send receive) bus=session path=/org/kde/Solid/PowerManagement{,/**}
       interface=org.kde.Solid.PowerManagement{,.*}
       peer=(name="{@{busname},org.kde.Solid.PowerManagement{,.*},org.freedesktop.DBus}", label=kde-powerdevil),
  dbus send bus=session path=/org/kde/Solid/PowerManagement{,/**}
       interface=org.kde.Solid.PowerManagement{,.*}
       peer=(name="org.kde.Solid.PowerManagement{,.*}"),
  # DBus.Properties: read and send properties
  dbus (send receive) bus=session path=/org/kde/Solid/PowerManagement{,/**}
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.kde.Solid.PowerManagement{,.*},org.freedesktop.DBus}", label=kde-powerdevil),
  # DBus.Introspectable: allow service introspection
  dbus send bus=session path=/org/kde/Solid/PowerManagement{,/**}
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="{@{busname},org.kde.Solid.PowerManagement{,.*},org.freedesktop.DBus}", label=kde-powerdevil),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus send bus=session path=/org/kde/Solid/PowerManagement{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.kde.Solid.PowerManagement{,.*},org.freedesktop.DBus}", label=kde-powerdevil),
  dbus receive bus=session path=/org/kde/Solid/PowerManagement{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.kde.Solid.PowerManagement{,.*},org.freedesktop.DBus}", label=kde-powerdevil),

  #aa/dbus talk bus=session name=org.kde.StatusNotifierWatcher path=/StatusNotifierWatcher label=kded
  # Unix: allow connection to the profile
  unix type=stream peer=(label=kded),
  # org.kde.StatusNotifierWatcher: send and receive anything to the interface on the specific peer label
  dbus (send receive) bus=session path=/StatusNotifierWatcher
       interface=org.kde.StatusNotifierWatcher{,.*}
       peer=(name="{@{busname},org.kde.StatusNotifierWatcher{,.*},org.freedesktop.DBus}", label=kded),
  dbus send bus=session path=/StatusNotifierWatcher
       interface=org.kde.StatusNotifierWatcher{,.*}
       peer=(name="org.kde.StatusNotifierWatcher{,.*}"),
  # DBus.Properties: read and send properties
  dbus (send receive) bus=session path=/StatusNotifierWatcher
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.kde.StatusNotifierWatcher{,.*},org.freedesktop.DBus}", label=kded),
  # DBus.Introspectable: allow service introspection
  dbus send bus=session path=/StatusNotifierWatcher
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="{@{busname},org.kde.StatusNotifierWatcher{,.*},org.freedesktop.DBus}", label=kded),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus send bus=session path=/StatusNotifierWatcher
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.kde.StatusNotifierWatcher{,.*},org.freedesktop.DBus}", label=kded),
  dbus receive bus=session path=/StatusNotifierWatcher
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.kde.StatusNotifierWatcher{,.*},org.freedesktop.DBus}", label=kded),


  @{exec_path} mr,

  @{lib}/libheif/            r,
  @{lib}/libheif/{,**}      mr,

  @{bin}/dolphin           rpx,
  @{bin}/ksysguardd       rpux,
  @{bin}/plasma-discover  rpux,
  @{bin}/xrdb              rpx,
  @{lib}/kf{5,6}/kdesu{,d} rix,

  /{,usr/}lib{,exec,32,64}/*-linux-gnu*/{,libexec/}kf5/kioslave5 Px,
  /{,usr/}lib{,exec,32,64}/*-linux-gnu*/{,libexec/}kf6/kioworker Px,
  /{,usr/}lib{,exec,32,64}/kf5/kioslave5 Px,
  /{,usr/}lib{,exec,32,64}/kf6/kioworker Px,

  /snap/*/@{uid}/**.@{image_ext} r,
  /usr/share/*/icons/{,**} r,
  /usr/share/akonadi/{,**} r,
  /usr/share/desktop-directories/kf5-*.directory r,
  /usr/share/kf{5,6}/{,**} r,
  /usr/share/kio/servicemenus/{,*.desktop} r,
  /usr/share/konsole/ r,
  /usr/share/krunner/{,**} r,
  /usr/share/kservices{5,6}/{,**} r,
  /usr/share/kservicetypes{5,6}/{,**} r,
  /usr/share/lshw/artwork/logo.svg r,
  /usr/share/metainfo/{,**} r,
  /usr/share/plasma/{,**} r,
  /usr/share/plasma5support/** r,
  /usr/share/qalculate/{,**} r,
  /usr/share/rider/{,**} r,
  /usr/share/solid/actions/{,**} r,
  /usr/share/swcatalog/{,**} r,
  /usr/share/templates/{,*.desktop} r,
  /usr/share/thumbnailers/{,*} r,
  /usr/share/wallpapers/{,**} r,

  /etc/appstream.conf r,
  /etc/fstab r,
  /etc/machine-id r,
  /etc/os-release r,
  /etc/sensors.d/ r,
  /etc/sensors3.conf r,
  /etc/xdg/** r,

  /var/lib/AccountsService/icons/* r,
  /var/lib/swcatalog/icons/**.png r,

  @{MOUNTS}/ r,
  @{system_games_dirs}/**.@{icon_ext} r,

        @{HOME}/ r,
  owner @{HOME}/.face r,
  owner @{HOME}/.mozilla/firefox/firefox-mpris/{,*} r,
  owner @{HOME}/.var/app/**.{png,jpg,svg} r,
  owner @{HOME}/@{XDG_DESKTOP_DIR}/* r,
  owner @{HOME}/@{XDG_WALLPAPERS_DIR}/{,**} r,
  owner @{user_games_dirs}/**.@{icon_ext} r,
  owner @{user_music_dirs}/**.@{icon_ext} r,
  owner @{user_pictures_dirs}/{,**} r,

  owner @{user_templates_dirs}/ r,

  owner @{user_cache_dirs}/ r,
  owner @{user_cache_dirs}/#@{int} rwk,
  owner @{user_cache_dirs}/appstream/ rw,
  owner @{user_cache_dirs}/appstream/*.xb rw,
  owner @{user_cache_dirs}/bookmarksrunner/ rw,
  owner @{user_cache_dirs}/bookmarksrunner/** rwkl -> @{user_cache_dirs}/bookmarksrunner/#@{int},
  owner @{user_cache_dirs}/kcrash-metadata/plasmashell.*.ini w,
  owner @{user_cache_dirs}/ksvg-elements rw,
  owner @{user_cache_dirs}/ksvg-elements.@{rand6} rwlk -> @{user_cache_dirs}/#@{int},
  owner @{user_cache_dirs}/ksvg-elements.lock rwlk,
  owner @{user_cache_dirs}/org.kde.dirmodel-qml.kcache rw,
  owner @{user_cache_dirs}/plasma_engine_potd/{,**} rw,
  owner @{user_cache_dirs}/plasma_theme_*.kcache rw,
  owner @{user_cache_dirs}/plasma-svgelements rw,
  owner @{user_cache_dirs}/plasma-svgelements.@{rand6} rwl -> @{user_cache_dirs}/#@{int},
  owner @{user_cache_dirs}/plasma-svgelements.lock rwk,
  owner @{user_cache_dirs}/plasmashell/ rw,
  owner @{user_cache_dirs}/plasmashell/** rwkl -> @{user_cache_dirs}/plasmashell/**,
  owner @{user_cache_dirs}/org.kde.*/ rw,
  owner @{user_cache_dirs}/org.kde.*/** rwlk,

  owner @{user_config_dirs}/{KDE,kde.org}/ rw,
  owner @{user_config_dirs}/{KDE,kde.org}/** rwkl -> @{user_config_dirs}/{KDE,kde.org}/#@{int},
  owner @{user_config_dirs}/*kde*.desktop* r,
  owner @{user_config_dirs}/#@{int} rwk,
  owner @{user_config_dirs}/akonadi* r,
  owner @{user_config_dirs}/akonadi/akonadi*rc r,
  owner @{user_config_dirs}/arkrc r,
  owner @{user_config_dirs}/baloofileinformationrc r,
  owner @{user_config_dirs}/breezerc r,
  owner @{user_config_dirs}/eventviewsrc r,
  owner @{user_config_dirs}/kactivitymanagerd* rwkl -> @{user_config_dirs}/#@{int},
  owner @{user_config_dirs}/kcookiejarrc r,
  owner @{user_config_dirs}/kdedefaults/plasmarc r,
  owner @{user_config_dirs}/kdiff3fileitemactionrc r,
  owner @{user_config_dirs}/kiorc r,
  owner @{user_config_dirs}/kioslaverc r,
  owner @{user_config_dirs}/klaunchrc r,
  owner @{user_config_dirs}/klipperrc r,
  owner @{user_config_dirs}/kmail2.notifyrc r,
  owner @{user_config_dirs}/knfsshare r,
  owner @{user_config_dirs}/konsole.notifyrc r,
  owner @{user_config_dirs}/korganizerrc r,
  owner @{user_config_dirs}/krunnerrc r,
  owner @{user_config_dirs}/ksmserverrc r,
  owner @{user_config_dirs}/kwalletrc r,
  owner @{user_config_dirs}/menus/{,**} r,
  owner @{user_config_dirs}/networkmanagement.notifyrc r,
  owner @{user_config_dirs}/PlasmaUserFeedback r,
  owner @{user_config_dirs}/plasma* rwlk,
  owner @{user_config_dirs}/kscreenlockerrc r,
  owner @{user_config_dirs}/Kvantum/{,**} r,

  @{user_share_dirs}/plasma/** rpux,

  owner @{user_share_dirs}/*/sessions/ r,
  owner @{user_share_dirs}/#@{int} rw,
  owner @{user_share_dirs}/akonadi/search_db/{,**} r,
  owner @{user_share_dirs}/kactivitymanagerd/resources/database rwk,
  owner @{user_share_dirs}/kactivitymanagerd/resources/database-shm rwk,
  owner @{user_share_dirs}/kactivitymanagerd/resources/database-wal rw,
  owner @{user_share_dirs}/kio/servicemenus/{,**} r,
  owner @{user_share_dirs}/klipper/{,**} rwlk,
  owner @{user_share_dirs}/konsole/ r,
  owner @{user_share_dirs}/kpeople/persondb rwk,
  owner @{user_share_dirs}/kpeoplevcard/ r,
  owner @{user_share_dirs}/krunnerstaterc rwl,
  owner @{user_share_dirs}/krunnerstaterc.@{rand6} rwl,
  owner @{user_share_dirs}/krunnerstaterc.lock rwk,
  owner @{user_share_dirs}/kservices{5,6}/{,**} r,
  owner @{user_share_dirs}/ktp/cache.db rwk,
  owner @{user_share_dirs}/libkunitconversion/ rw,
  owner @{user_share_dirs}/libkunitconversion/** rwlk,
  owner @{user_share_dirs}/plasma_icons/*.desktop r,
  owner @{user_share_dirs}/plasma/{,**} r,
  owner @{user_share_dirs}/plasmashell/** rwkl -> @{user_share_dirs}/plasmashell/**,
  owner @{user_share_dirs}/qalculate/{,**} r,
  owner @{user_share_dirs}/user-places.xbel{,*} rwl,
  owner @{user_share_dirs}/wallpapers/{,**} rw,
  owner @{user_share_dirs}/knotifications6/apdatifier.notifyrc r,

  owner @{user_state_dirs}/#@{int} rw,
  owner @{user_state_dirs}/kickerstaterc r,
  owner @{user_state_dirs}/plasma/* r,
  owner @{user_state_dirs}/plasmashellstaterc rw,
  owner @{user_state_dirs}/plasmashellstaterc.@{rand6} rwl,
  owner @{user_state_dirs}/plasmashellstaterc.lock rwk,
  owner @{user_state_dirs}/UserFeedback.org.kde.plasmashell rw,
  owner @{user_state_dirs}/UserFeedback.org.kde.plasmashell.@{rand6} rwl,
  owner @{user_state_dirs}/UserFeedback.org.kde.plasmashell.lock rwk,

        /tmp/.mount_nextcl@{rand6}/{,*} r,
  owner @{tmp}/#@{int} rw,
  owner @{tmp}/plasma-browser-integration_artwork_@{rand6}.jpg r,

        @{run}/mount/utab r,
        @{run}/user/@{uid}/gvfs/ r,
  owner @{run}/user/@{uid}/#@{int} rw,
  owner @{run}/user/@{uid}/app/*/*.@{rand6} r,
  owner @{run}/user/@{uid}/kdesud_:@{int} w,
  owner @{run}/user/@{uid}/plasmashell@{rand6}.@{int}.kioworker.socket rwl -> @{run}/user/@{uid}/#@{int},

  @{sys}/bus/ r,
  @{sys}/bus/usb/devices/ r,
  @{sys}/class/{,**} r,
  @{sys}/devices/platform/** r,

  @{sys}/devices/@{pci}/name r,
  @{sys}/devices/virtual/thermal/**/{name,type} r,
  @{sys}/devices/virtual/thermal/thermal_zone@{int}/hwmon@{int}/ r,

        @{PROC}/ r,
        @{PROC}/@{pid}/cmdline r,
        @{PROC}/@{pid}/stat r,
        @{PROC}/cmdline r,
        @{PROC}/diskstats r,
        @{PROC}/loadavg r,
        @{PROC}/uptime r,
        @{PROC}/vmstat r,
  owner @{PROC}/@{pid}/{cgroup,cmdline,stat,statm} r,
  owner @{PROC}/@{pid}/attr/current r,
  owner @{PROC}/@{pid}/environ r,
  owner @{PROC}/@{pid}/mountinfo r,
  owner @{PROC}/@{pid}/mounts r,
  owner @{PROC}/@{pid}/task/@{tid}/comm rw,

  /dev/ptmx rw,
  /dev/rfkill r,

  include if exists <local/plasmashell>
}

# vim:syntax=apparmor
