# apparmor.d - Full set of apparmor profiles
# Copyright (C) 2023-2024 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: GPL-2.0-only

abi <abi/4.0>,

include <tunables/global>

@{appid} = @{word}.@{word}.@{word}{,.@{word}}

@{exec_path} = @{bin}/flatpak
@{att} = /att/flatpak/
profile flatpak /{,usr/}bin/flatpak flags=(attach_disconnected,attach_disconnected.path=@{att},mediate_deleted,complain) {
  include <abstractions/attached/base>
  include <abstractions/accessibility>
  include <abstractions/accounts-observe>
  include <abstractions/bus-session>
  include <abstractions/bus-system>
  include <abstractions/bus/session/org.freedesktop.impl.portal.PermissionStore>
  include <abstractions/bus/session/org.gtk.vfs.MountTracker>
  include <abstractions/bus/system/org.freedesktop.locale1>
  include <abstractions/attached/consoles>
  include <abstractions/dconf-write>
  include <abstractions/desktop-files>
  include <abstractions/gschemas>
  include <abstractions/mime>
  include <abstractions/attached/nameservice-strict>
  include <abstractions/ssl_certs>
  include <abstractions/user-dirs>

  capability dac_override,
  capability dac_read_search,
  capability net_admin,
  capability sys_ptrace,
  capability syslog, # optional: no audit

  # Manage the sandbox
  capability setgid,
  capability setuid,
  capability sys_admin,
  capability sys_chroot,

  network inet dgram,
  network inet6 dgram,
  network inet stream,
  network inet6 stream,
  network netlink raw,

  mount fstype=fuse.revokefs-fuse options=(rw, nosuid, nodev) -> /var/tmp/flatpak-cache-*/*/,

  ptrace read peer=bwrap.*,     # bwrap for experimental per app generated profile
  ptrace read peer=fbwrap,      # Generic bwrap for flatpak app
  ptrace read peer=flatpak-app, # Deprecated generic profile
  ptrace read peer=flatpak.*,

  signal send peer=flatpak-app,
  signal send peer=polkit-agent-helper,

  unix type=seqpacket peer=(label=flatpak-system-helper),
  unix type=stream    peer=(label=flatpak//fusermount),
  unix (send receive) type=seqpacket peer=(label=fapp),
  unix (send receive) type=seqpacket peer=(label=fbwrap),

  #aa/dbus talk bus=system name=org.freedesktop.Flatpak.SystemHelper label=flatpak-system-helper
  # Unix: allow connection to the profile
  unix type=stream peer=(label=flatpak-system-helper),
  # org.freedesktop.Flatpak.SystemHelper: send and receive anything to the interface on the specific peer label
  dbus (send receive) bus=system path=/org/freedesktop/Flatpak/SystemHelper{,/**}
       interface=org.freedesktop.Flatpak.SystemHelper{,.*}
       peer=(name="{@{busname},org.freedesktop.Flatpak.SystemHelper{,.*},org.freedesktop.DBus}", label=flatpak-system-helper),
  dbus send bus=system path=/org/freedesktop/Flatpak/SystemHelper{,/**}
       interface=org.freedesktop.Flatpak.SystemHelper{,.*}
       peer=(name="org.freedesktop.Flatpak.SystemHelper{,.*}"),
  # DBus.Properties: read and send properties
  dbus (send receive) bus=system path=/org/freedesktop/Flatpak/SystemHelper{,/**}
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.freedesktop.Flatpak.SystemHelper{,.*},org.freedesktop.DBus}", label=flatpak-system-helper),
  # DBus.Introspectable: allow service introspection
  dbus send bus=system path=/org/freedesktop/Flatpak/SystemHelper{,/**}
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="{@{busname},org.freedesktop.Flatpak.SystemHelper{,.*},org.freedesktop.DBus}", label=flatpak-system-helper),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus send bus=system path=/org/freedesktop/Flatpak/SystemHelper{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.freedesktop.Flatpak.SystemHelper{,.*},org.freedesktop.DBus}", label=flatpak-system-helper),
  dbus receive bus=system path=/org/freedesktop/Flatpak/SystemHelper{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.Flatpak.SystemHelper{,.*},org.freedesktop.DBus}", label=flatpak-system-helper),

  #aa/dbus talk bus=system name=org.freedesktop.PolicyKit1 label="@{p_polkitd}"
  # Unix: allow connection to the profile
  unix type=stream peer=(label="@{p_polkitd}"),
  # org.freedesktop.PolicyKit1: send and receive anything to the interface on the specific peer label
  dbus (send receive) bus=system path=/org/freedesktop/PolicyKit1{,/**}
       interface=org.freedesktop.PolicyKit1{,.*}
       peer=(name="{@{busname},org.freedesktop.PolicyKit1{,.*},org.freedesktop.DBus}", label="@{p_polkitd}"),
  dbus send bus=system path=/org/freedesktop/PolicyKit1{,/**}
       interface=org.freedesktop.PolicyKit1{,.*}
       peer=(name="org.freedesktop.PolicyKit1{,.*}"),
  # DBus.Properties: read and send properties
  dbus (send receive) bus=system path=/org/freedesktop/PolicyKit1{,/**}
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.freedesktop.PolicyKit1{,.*},org.freedesktop.DBus}", label="@{p_polkitd}"),
  # DBus.Introspectable: allow service introspection
  dbus send bus=system path=/org/freedesktop/PolicyKit1{,/**}
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="{@{busname},org.freedesktop.PolicyKit1{,.*},org.freedesktop.DBus}", label="@{p_polkitd}"),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus send bus=system path=/org/freedesktop/PolicyKit1{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.freedesktop.PolicyKit1{,.*},org.freedesktop.DBus}", label="@{p_polkitd}"),
  dbus receive bus=system path=/org/freedesktop/PolicyKit1{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.PolicyKit1{,.*},org.freedesktop.DBus}", label="@{p_polkitd}"),


  #aa/dbus talk bus=session name=org.freedesktop.Flatpak.SessionHelper label=flatpak-session-helper
  # Unix: allow connection to the profile
  unix type=stream peer=(label=flatpak-session-helper),
  # org.freedesktop.Flatpak.SessionHelper: send and receive anything to the interface on the specific peer label
  dbus (send receive) bus=session path=/org/freedesktop/Flatpak/SessionHelper{,/**}
       interface=org.freedesktop.Flatpak.SessionHelper{,.*}
       peer=(name="{@{busname},org.freedesktop.Flatpak.SessionHelper{,.*},org.freedesktop.DBus}", label=flatpak-session-helper),
  dbus send bus=session path=/org/freedesktop/Flatpak/SessionHelper{,/**}
       interface=org.freedesktop.Flatpak.SessionHelper{,.*}
       peer=(name="org.freedesktop.Flatpak.SessionHelper{,.*}"),
  # DBus.Properties: read and send properties
  dbus (send receive) bus=session path=/org/freedesktop/Flatpak/SessionHelper{,/**}
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.freedesktop.Flatpak.SessionHelper{,.*},org.freedesktop.DBus}", label=flatpak-session-helper),
  # DBus.Introspectable: allow service introspection
  dbus send bus=session path=/org/freedesktop/Flatpak/SessionHelper{,/**}
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="{@{busname},org.freedesktop.Flatpak.SessionHelper{,.*},org.freedesktop.DBus}", label=flatpak-session-helper),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus send bus=session path=/org/freedesktop/Flatpak/SessionHelper{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.freedesktop.Flatpak.SessionHelper{,.*},org.freedesktop.DBus}", label=flatpak-session-helper),
  dbus receive bus=session path=/org/freedesktop/Flatpak/SessionHelper{,/**}
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.Flatpak.SessionHelper{,.*},org.freedesktop.DBus}", label=flatpak-session-helper),

  #aa/dbus talk bus=session name=org.freedesktop.portal.Documents path=/org/freedesktop/portal/documents label=xdg-document-portal
  # Unix: allow connection to the profile
  unix type=stream peer=(label=xdg-document-portal),
  # org.freedesktop.portal.Documents: send and receive anything to the interface on the specific peer label
  dbus (send receive) bus=session path=/org/freedesktop/portal/documents
       interface=org.freedesktop.portal.Documents{,.*}
       peer=(name="{@{busname},org.freedesktop.portal.Documents{,.*},org.freedesktop.DBus}", label=xdg-document-portal),
  dbus send bus=session path=/org/freedesktop/portal/documents
       interface=org.freedesktop.portal.Documents{,.*}
       peer=(name="org.freedesktop.portal.Documents{,.*}"),
  # DBus.Properties: read and send properties
  dbus (send receive) bus=session path=/org/freedesktop/portal/documents
       interface=org.freedesktop.DBus.Properties
       member={Get,GetAll,Set,PropertiesChanged}
       peer=(name="{@{busname},org.freedesktop.portal.Documents{,.*},org.freedesktop.DBus}", label=xdg-document-portal),
  # DBus.Introspectable: allow service introspection
  dbus send bus=session path=/org/freedesktop/portal/documents
       interface=org.freedesktop.DBus.Introspectable
       member=Introspect
       peer=(name="{@{busname},org.freedesktop.portal.Documents{,.*},org.freedesktop.DBus}", label=xdg-document-portal),
  # DBus.ObjectManager: allow clients to enumerate sources
  dbus send bus=session path=/org/freedesktop/portal/documents
       interface=org.freedesktop.DBus.ObjectManager
       member=GetManagedObjects
       peer=(name="{@{busname},org.freedesktop.portal.Documents{,.*},org.freedesktop.DBus}", label=xdg-document-portal),
  dbus receive bus=session path=/org/freedesktop/portal/documents
       interface=org.freedesktop.DBus.ObjectManager
       member={InterfacesAdded,InterfacesRemoved}
       peer=(name="{@{busname},org.freedesktop.portal.Documents{,.*},org.freedesktop.DBus}", label=xdg-document-portal),


  dbus send bus=system path=/org/freedesktop/Flatpak/SystemHelper
       interface=org.freedesktop.Flatpak.SystemHelper
       member=GetRevokefsFd
       peer=(name=org.freedesktop.Flatpak.SystemHelper),

  dbus send bus=session path=/org/freedesktop/DBus
       interface=org.freedesktop.DBus
       member=ReloadConfig
       peer=(name=org.freedesktop.DBus, label="@{p_systemd_user}"),

  @{exec_path} mr,


  @{bin}/bwrap               rpx -> fbwrap,
  @{bin}/fusermount{,3}      rcx -> fusermount,
  @{bin}/gpg                 rcx -> gpg,
  @{bin}/gpgconf             rcx -> gpg,
  @{bin}/gpgsm               rcx -> gpg,
  @{lib}/revokefs-fuse       rix,
  @{lib}/flatpak-validate-icon rpx,

  # For flatpack enter, the shell is not confined on purpose.
  @{bin}/@{shells}           rux,

  @{lib}/polkit-[0-9]/polkit-agent-helper-[0-9]  rpx,
  @{lib}/polkit-agent-helper-[0-9]               rpx,

  /usr/share/flatpak/{,**} r,

  /etc/flatpak/{,**} r,
  /etc/pulse/client.conf r,

        / r,
  @{att}/ r,

  /var/lib/flatpak/{,**} rwlk,

        /var/tmp/#@{int} rw,
        /var/tmp/flatpak-cache-@{rand6}/{,**/} r,
  owner /var/tmp/flatpak-cache-@{rand6}/ rw,
  owner /var/tmp/flatpak-cache-@{rand6}/** rwlk -> /var/tmp/flatpak-cache-@{rand6}/**,

  owner @{HOME}/.var/ w,
  owner @{HOME}/.var/app/{,**} rw,
  owner @{att}@{HOME}/.var/app/@{appid}/.local/share/*/logs/* rw,
  owner @{att}@{HOME}/.var/app/@{appid}/.local/share/*/**/usr/.ref rw,

  # Can create dotfile directories for any app
  owner @{user_cache_dirs}/*/ w,
  owner @{user_config_dirs}/*/ w,
  owner @{user_share_dirs}/*/ w,
  owner @{user_games_dirs}/{,**/} w,
  owner @{user_documents_dirs}/ w,

        @{user_config_dirs}/dconf/user r,
  owner @{user_cache_dirs}/flatpak/{,**} rw,
  owner @{user_config_dirs}/pulse/client.conf r,
  owner @{user_config_dirs}/user-dirs.dirs r,

        @{user_share_dirs}/flatpak/{,**} r,
  owner @{user_share_dirs}/ r,
  owner @{user_share_dirs}/flatpak/ rw,
  owner @{user_share_dirs}/flatpak/** rwlk,

  owner @{tmp}/#@{int} rw,
  owner @{tmp}/ostree-gpg-@{rand6}/{,**} rw,
  owner @{tmp}/remote-summary-sig.@{rand6} rw,
  owner @{tmp}/remote-summary.@{rand6} rw,
  owner /dev/shm/flatpak*/{,**} rw,

  @{att}@{run}/.userns r,
  @{run}/polkit/agent-helper.socket rw,

        @{run}/user/@{uid}/.dbus-proxy/ w,
        @{run}/user/@{uid}/dconf/user rw,
  owner @{run}/user/@{uid}/.dbus-proxy/* rw,
  owner @{run}/user/@{uid}/.flatpak-cache rw,
  owner @{run}/user/@{uid}/.flatpak/ rw,
  owner @{run}/user/@{uid}/.flatpak/** rwlk -> @{run}/user/@{uid}/.flatpak/**,
  owner @{run}/user/@{uid}/.mutter-Xwaylandauth.@{rand6} r,
  owner @{run}/user/@{uid}/app/ w,
  owner @{run}/user/@{uid}/app/*/ w,
  owner @{run}/user/@{uid}/systemd/private rw,
  owner @{run}/user/@{uid}/wayland-@{int} rw,

  @{sys}/module/nvidia/version r,

        @{PROC}/modules r,
        @{PROC}/sys/fs/pipe-max-size r,
  owner @{PROC}/@{pid}/cgroup r,
  owner @{PROC}/@{pid}/fdinfo/@{int} r,
  owner @{PROC}/@{pid}/stat r,

  /dev/fuse rw,
  /dev/tty rw,
  /dev/tty@{u8} rw,

  profile gpg flags=(attach_disconnected,attach_disconnected.path=@{att},mediate_deleted,complain) {
    include <abstractions/attached/base>
    include <abstractions/attached/consoles>

    capability dac_read_search,

    @{bin}/gpg{,2}    mr,
    @{bin}/gpgconf    mr,
    @{bin}/gpgsm      mr,
    @{bin}/gpg-agent  rix,
    @{lib}/gnupg/scdaemon rix,

    @{HOME}/@{XDG_GPG_DIR}/*.conf r,

    owner @{tmp}/ostree-gpg-@{rand6}/ rw,
    owner @{tmp}/ostree-gpg-@{rand6}/** rwkl -> /tmp/ostree-gpg-@{rand6}/**,

    owner @{PROC}/@{pid}/fd/ r,

    include if exists <local/flatpak_gpg>
  }

  profile fusermount flags=(attach_disconnected,attach_disconnected.path=@{att},mediate_deleted,complain) {
    include <abstractions/attached/base>
    include <abstractions/app/fusermount>

    capability setuid,

    unix type=seqpacket peer=(label=flatpak-system-helper),
    unix type=stream    peer=(label=flatpak),

    mount fstype=fuse.revokefs-fuse options=(rw, nosuid, nodev) revokefs-fuse -> /var/tmp/flatpak-cache-*/*/,
    umount /var/tmp/flatpak-cache-*/*/,

      include if exists <local/flatpak_fusermount>
  }

  include if exists <local/flatpak>
}

# vim:syntax=apparmor
