class profile::weblogic::base::ssh(
  $user   = 'oracle',
  $group  = 'sdba',
  $source = '/vagrant/ssh'
) {

  require os

  file { "/home/${user}/.ssh/":
    owner  => $user,
    group  => $group,
    mode   => '0700',
    ensure => 'directory',
    alias  => "${user}-ssh-dir",
  }

  file { "/home/${user}/.ssh/id_rsa.pub":
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    source  => "${source}/id_rsa.pub",
    require => File["${user}-ssh-dir"],
  }

  file { "/home/${user}/.ssh/id_rsa":
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0600',
    source  => "${source}/id_rsa",
    require => File["${user}-ssh-dir"],
  }

  file { "/home/${user}/.ssh/authorized_keys":
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    source  => "${source}/id_rsa.pub",
    require => File["${user}-ssh-dir"],
  }

}
