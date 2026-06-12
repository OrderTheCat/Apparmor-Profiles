# apparmor.d - Full set of apparmor profiles
# Copyright (C) 2021-2024 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: GPL-2.0-only

abi <abi/4.0>,

include <tunables/global>

@{exec_path} = @{bin}/nautilus
@{att} = /att/nautilus/
profile nautilus /{,usr/}bin/nautilus flags=(attach_disconnected,attach_disconnected.path=@{att},complain) {
  include <abstractions/attached/base>
  include <abstractions/bus/session/com.canonical.Unity.LauncherEntry>
  include <abstractions/bus/session/org.freedesktop.portal.Inhibit>
  include <abstractions/bus/session/org.freedesktop.Tracker3.Miner.Files>
  include <abstractions/bus/session/org.gtk.Private.RemoteVolumeMonitor>
  include <abstractions/bus/system/org.freedesktop.hostname1>
  include <abstractions/dconf-write>
  include <abstractions/deny-sensitive-home>
  include <abstractions/gnome-strict>
  include <abstractions/graphics>
  include <abstractions/attached/nameservice-strict>
  include <abstractions/screen-inhibit>
  include <abstractions/sys/hwmon-fan>
  include <abstractions/sys/hwmon-temp>
  include <abstractions/trash-strict>

  mqueue r type=posix /,

  unix type=stream peer=(label=gnome-shell),

  signal send set=kill peer=gnome-desktop-thumbnailers,

  #aa/dbus own bus=session name=org.freedesktop.FileManager1
  include <abstractions/bus/session/own>
  dbus bind bus=session name=org.freedesktop.FileManager1{,.*},
  dbus receive bus=session path=/org/freedesktop/FileManager1{,/**}
       interface=org.freedesktop.FileManager1{,.*}
       peer=(name="@{busname}"),
  dbus send bus=session path=/org/freedesktop/FileManager1{,/**}
       interface=org.freedesktop.FileManager1{,.*}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Properties: reply to properties request from anyone
  dbus (send receive) bus=session path=/org/freedesktop/FileManager1{,/**}
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Introspectable: allow clients to introspect the service
  dbus receive bus=session path=/org/freedesktop/FileManager1{,/**}
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="@{busname}"),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus receive bus=session path=/org/freedesktop/FileManager1{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.freedesktop.FileManager1{,.*}}"),
  dbus send bus=session path=/org/freedesktop/FileManager1{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.DBus}"),

  #aa/dbus own bus=session name=org.gnome.Nautilus.SearchProvider interface+=org.gnome.Shell.SearchProvider2
  dbus bind bus=session name=org.gnome.Nautilus.SearchProvider{,.*},
  dbus receive bus=session path=/org/gnome/Nautilus/SearchProvider{,/**}
       interface=org.gnome.Nautilus.SearchProvider{,.*}
       peer=(name="@{busname}"),
  dbus send bus=session path=/org/gnome/Nautilus/SearchProvider{,/**}
       interface=org.gnome.Nautilus.SearchProvider{,.*}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  dbus receive bus=session path=/org/gnome/Nautilus/SearchProvider{,/**}
       interface=org.gnome.Shell.SearchProvider2
       peer=(name="@{busname}"),
  dbus send bus=session path=/org/gnome/Nautilus/SearchProvider{,/**}
       interface=org.gnome.Shell.SearchProvider2
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Properties: reply to properties request from anyone
  dbus (send receive) bus=session path=/org/gnome/Nautilus/SearchProvider{,/**}
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Introspectable: allow clients to introspect the service
  dbus receive bus=session path=/org/gnome/Nautilus/SearchProvider{,/**}
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="@{busname}"),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus receive bus=session path=/org/gnome/Nautilus/SearchProvider{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.gnome.Nautilus.SearchProvider{,.*}}"),
  dbus send bus=session path=/org/gnome/Nautilus/SearchProvider{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.DBus}"),

  #aa/dbus own bus=session name=org.gnome.Nautilus
  dbus bind bus=session name=org.gnome.Nautilus{,.*},
  dbus receive bus=session path=/org/gnome/Nautilus{,/**}
       interface=org.gnome.Nautilus{,.*}
       peer=(name="@{busname}"),
  dbus send bus=session path=/org/gnome/Nautilus{,/**}
       interface=org.gnome.Nautilus{,.*}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Properties: reply to properties request from anyone
  dbus (send receive) bus=session path=/org/gnome/Nautilus{,/**}
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.freedesktop.DBus}"),
  # DBus.Introspectable: allow clients to introspect the service
  dbus receive bus=session path=/org/gnome/Nautilus{,/**}
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="@{busname}"),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus receive bus=session path=/org/gnome/Nautilus{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.gnome.Nautilus{,.*}}"),
  dbus send bus=session path=/org/gnome/Nautilus{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.DBus}"),


  #aa/dbus talk bus=session name=org.freedesktop.impl.portal.FileChooser path=/org/freedesktop/portal/desktop label=xdg-desktop-portal-gnome
  # Unix: allow connection to the profile
  unix type=stream peer=(label=xdg-desktop-portal-gnome),
  # org.freedesktop.impl.portal.FileChooser: send and receive anything to the interface on the specific peer label
  dbus (send receive) bus=session path=/org/freedesktop/portal/desktop
       interface=org.freedesktop.impl.portal.FileChooser{,.*}
       peer=(name="{@{busname},org.freedesktop.impl.portal.FileChooser{,.*},org.freedesktop.DBus}", label=xdg-desktop-portal-gnome),
  dbus send bus=session path=/org/freedesktop/portal/desktop
       interface=org.freedesktop.impl.portal.FileChooser{,.*}
       peer=(name="org.freedesktop.impl.portal.FileChooser{,.*}"),
  # DBus.Properties: read and send properties
  dbus (send receive) bus=session path=/org/freedesktop/portal/desktop
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.freedesktop.impl.portal.FileChooser{,.*},org.freedesktop.DBus}", label=xdg-desktop-portal-gnome),
  # DBus.Introspectable: allow service introspection
  dbus send bus=session path=/org/freedesktop/portal/desktop
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="{@{busname},org.freedesktop.impl.portal.FileChooser{,.*},org.freedesktop.DBus}", label=xdg-desktop-portal-gnome),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus send bus=session path=/org/freedesktop/portal/desktop
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.freedesktop.impl.portal.FileChooser{,.*},org.freedesktop.DBus}", label=xdg-desktop-portal-gnome),
  dbus receive bus=session path=/org/freedesktop/portal/desktop
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.impl.portal.FileChooser{,.*},org.freedesktop.DBus}", label=xdg-desktop-portal-gnome),

  #aa/dbus talk bus=session name=org.freedesktop.portal.FileTransfer path=/org/freedesktop/portal/documents label=xdg-document-portal
  # Unix: allow connection to the profile
  unix type=stream peer=(label=xdg-document-portal),
  # org.freedesktop.portal.FileTransfer: send and receive anything to the interface on the specific peer label
  dbus (send receive) bus=session path=/org/freedesktop/portal/documents
       interface=org.freedesktop.portal.FileTransfer{,.*}
       peer=(name="{@{busname},org.freedesktop.portal.FileTransfer{,.*},org.freedesktop.DBus}", label=xdg-document-portal),
  dbus send bus=session path=/org/freedesktop/portal/documents
       interface=org.freedesktop.portal.FileTransfer{,.*}
       peer=(name="org.freedesktop.portal.FileTransfer{,.*}"),
  # DBus.Properties: read and send properties
  dbus (send receive) bus=session path=/org/freedesktop/portal/documents
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.freedesktop.portal.FileTransfer{,.*},org.freedesktop.DBus}", label=xdg-document-portal),
  # DBus.Introspectable: allow service introspection
  dbus send bus=session path=/org/freedesktop/portal/documents
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="{@{busname},org.freedesktop.portal.FileTransfer{,.*},org.freedesktop.DBus}", label=xdg-document-portal),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus send bus=session path=/org/freedesktop/portal/documents
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.freedesktop.portal.FileTransfer{,.*},org.freedesktop.DBus}", label=xdg-document-portal),
  dbus receive bus=session path=/org/freedesktop/portal/documents
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.portal.FileTransfer{,.*},org.freedesktop.DBus}", label=xdg-document-portal),

  #aa/dbus talk bus=session name=org.gnome.Settings label=gnome-control-center
  # Unix: allow connection to the profile
  unix type=stream peer=(label=gnome-control-center),
  # org.gnome.Settings: send and receive anything to the interface on the specific peer label
  dbus (send receive) bus=session path=/org/gnome/Settings{,/**}
       interface=org.gnome.Settings{,.*}
       peer=(name="{@{busname},org.gnome.Settings{,.*},org.freedesktop.DBus}", label=gnome-control-center),
  dbus send bus=session path=/org/gnome/Settings{,/**}
       interface=org.gnome.Settings{,.*}
       peer=(name="org.gnome.Settings{,.*}"),
  # DBus.Properties: read and send properties
  dbus (send receive) bus=session path=/org/gnome/Settings{,/**}
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.gnome.Settings{,.*},org.freedesktop.DBus}", label=gnome-control-center),
  # DBus.Introspectable: allow service introspection
  dbus send bus=session path=/org/gnome/Settings{,/**}
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="{@{busname},org.gnome.Settings{,.*},org.freedesktop.DBus}", label=gnome-control-center),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus send bus=session path=/org/gnome/Settings{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.gnome.Settings{,.*},org.freedesktop.DBus}", label=gnome-control-center),
  dbus receive bus=session path=/org/gnome/Settings{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.gnome.Settings{,.*},org.freedesktop.DBus}", label=gnome-control-center),

  #aa/dbus talk bus=session name=org.gtk.MountOperationHandler label=gnome-shell
  # Unix: allow connection to the profile
  unix type=stream peer=(label=gnome-shell),
  # org.gtk.MountOperationHandler: send and receive anything to the interface on the specific peer label
  dbus (send receive) bus=session path=/org/gtk/MountOperationHandler{,/**}
       interface=org.gtk.MountOperationHandler{,.*}
       peer=(name="{@{busname},org.gtk.MountOperationHandler{,.*},org.freedesktop.DBus}", label=gnome-shell),
  dbus send bus=session path=/org/gtk/MountOperationHandler{,/**}
       interface=org.gtk.MountOperationHandler{,.*}
       peer=(name="org.gtk.MountOperationHandler{,.*}"),
  # DBus.Properties: read and send properties
  dbus (send receive) bus=session path=/org/gtk/MountOperationHandler{,/**}
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.gtk.MountOperationHandler{,.*},org.freedesktop.DBus}", label=gnome-shell),
  # DBus.Introspectable: allow service introspection
  dbus send bus=session path=/org/gtk/MountOperationHandler{,/**}
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="{@{busname},org.gtk.MountOperationHandler{,.*},org.freedesktop.DBus}", label=gnome-shell),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus send bus=session path=/org/gtk/MountOperationHandler{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.gtk.MountOperationHandler{,.*},org.freedesktop.DBus}", label=gnome-shell),
  dbus receive bus=session path=/org/gtk/MountOperationHandler{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.gtk.MountOperationHandler{,.*},org.freedesktop.DBus}", label=gnome-shell),

  #aa/dbus talk bus=session name=org.gtk.Notifications label=gnome-shell
  # Unix: allow connection to the profile
  unix type=stream peer=(label=gnome-shell),
  # org.gtk.Notifications: send and receive anything to the interface on the specific peer label
  dbus (send receive) bus=session path=/org/gtk/Notifications{,/**}
       interface=org.gtk.Notifications{,.*}
       peer=(name="{@{busname},org.gtk.Notifications{,.*},org.freedesktop.DBus}", label=gnome-shell),
  dbus send bus=session path=/org/gtk/Notifications{,/**}
       interface=org.gtk.Notifications{,.*}
       peer=(name="org.gtk.Notifications{,.*}"),
  # DBus.Properties: read and send properties
  dbus (send receive) bus=session path=/org/gtk/Notifications{,/**}
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.gtk.Notifications{,.*},org.freedesktop.DBus}", label=gnome-shell),
  # DBus.Introspectable: allow service introspection
  dbus send bus=session path=/org/gtk/Notifications{,/**}
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="{@{busname},org.gtk.Notifications{,.*},org.freedesktop.DBus}", label=gnome-shell),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus send bus=session path=/org/gtk/Notifications{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.gtk.Notifications{,.*},org.freedesktop.DBus}", label=gnome-shell),
  dbus receive bus=session path=/org/gtk/Notifications{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.gtk.Notifications{,.*},org.freedesktop.DBus}", label=gnome-shell),

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


  dbus send bus=session path=/org/gnome/Mutter/ServiceChannel
       interface=org.gnome.Mutter.ServiceChannel
       member=OpenWaylandServiceConnection
       peer=(name=@{busname}, label=gnome-shell),

  dbus (send, receive) bus=session path=/org/gtk/Application/CommandLine
       interface=org.gtk.private.CommandLine
       member=Print
       peer=(name=@{busname}, label=nautilus),

  dbus send bus=session path=/org/freedesktop/DBus
       interface=org.freedesktop.DBus.Properties
       member=GetAll
       peer=(name=org.freedesktop.DBus, label="@{p_dbus_session}"),

  dbus send bus=session path=/org/freedesktop/DBus
       interface=org.freedesktop.DBus
       member=ListActivatableNames
       peer=(name=org.freedesktop.DBus, label="@{p_dbus_session}"),

  dbus send bus=session path=/org/freedesktop/dbus
       interface=org.freedesktop.DBus
       member=NameHasOwner
       peer=(name=org.freedesktop.DBus, label="@{p_dbus_session}"),

  # Server side of abstractions/bus/session/org.freedesktop.Application
  dbus send bus=session
       interface=org.freedesktop.Application
       member=Open,

  @{exec_path} mr,

  @{sh_path}                 rix,
  @{bin}/bwrap               rpx -> gnome-desktop-thumbnailers,
  @{bin}/file-roller         rpx,
  @{bin}/firejail           rpux,
  @{bin}/net                rpux,

  @{bin}/* r,

  @{open_path}              mrpx -> child-open-any,

  /snap/*/@{uid}/**.@{icon_ext} r,
  /usr/share/**.@{icon_ext} r,
  /usr/share/nautilus/{,**} r,
  /usr/share/sounds/freedesktop/stereo/*.oga r,
  /usr/share/terminfo/** r,
  /usr/share/thumbnailers/{,**} r,
  /usr/share/tracker*/{,**} r,

  /etc/fstab r,

  /var/cache/fontconfig/ rw,

  #aa:lint ignore=too-wide
  # Full access to user's data
  / r,
  /*/ r,
  @{bin}/ r,
  @{lib}/ r,
  @{MOUNTDIRS}/ r,
  @{MOUNTS}/ r,
  @{MOUNTS}/** rw,
  owner @{HOME}/ r,
  owner @{HOME}/** rw,
  owner @{run}/user/@{uid}/ r,
  owner @{run}/user/@{uid}/** rw,
  owner @{tmp}/ r,
  owner @{tmp}/** rw,

  # Silence non user's data
  deny @{efi}/{,**} r,
  deny /opt/{,**} r,
  deny /root/{,**} r,
  deny /tmp/.* rw,
  deny /tmp/.*/{,**} rw,

  owner @{user_share_dirs}/nautilus/{,**} rwk,

  @{run}/mount/utab r,

        @{PROC}/@{pids}/net/wireless r,
        @{PROC}/sys/dev/i915/perf_stream_paranoid r,
  owner @{PROC}/@{pid}/cgroup r,
  owner @{PROC}/@{pid}/cmdline r,
  owner @{PROC}/@{pid}/fd/ r,
  owner @{PROC}/@{pid}/mountinfo r,
  owner @{PROC}/@{pid}/stat r,
  owner @{PROC}/@{pid}/task/@{tid}/comm rw,

  /dev/tty rw,

  include if exists <local/nautilus>
}

# vim:syntax=apparmor
