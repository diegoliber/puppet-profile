# "dbcdb.example.com" => {
#   ip           => "192.168.33.10",
#   host_aliases => "dbcdb"
# },

class profile::oracle::base (
  $os_user = "oracle",
  $hosts = {
    "localhost" => {
      ip            => "127.0.0.1",
      host_aliases  => 'localhost.localdomain,localhost4,localhost4.localdomain4'
    }
  }
) {

  # set the tmpfs
  mount { '/dev/shm':
    ensure      => present,
    atboot      => true,
    device      => 'tmpfs',
    fstype      => 'tmpfs',
    options     => 'size=1000m',
  }

  create_resources('host', $hosts)

  # service { iptables:
  #   enable    => false,
  #   ensure    => false,
  #   hasstatus => true,
  # }

  $all_groups = ['oinstall','dba' ,'oper','sdba']

  group { $all_groups :
    ensure      => present,
  }

  user { $os_user :
    ensure      => present,
    #uid         => 500,
    gid         => 'oinstall',
    groups      => $all_groups,
    shell       => '/bin/bash',
    password    => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',
    home        => '/home/oracle',
    comment     => 'This user oracle was created by Puppet',
    require     => Group[$all_groups],
    managehome  => true,
  }

  $install = ['binutils.x86_64', 'compat-libstdc++-33.x86_64', 'glibc.x86_64',
              'ksh.x86_64','libaio.x86_64',
              'libgcc.x86_64', 'libstdc++.x86_64', 'make.x86_64',
              'compat-libcap1.x86_64', 'gcc.x86_64',
              'gcc-c++.x86_64','glibc-devel.x86_64','libaio-devel.x86_64',
              'libstdc++-devel.x86_64',
              'sysstat.x86_64','unixODBC-devel','glibc.i686','libXext.x86_64',
              'libXtst.x86_64','xorg-x11-xauth.x86_64',
              'elfutils-libelf-devel','kernel-debug']


  package { $install:
    ensure  => present,
  }

  class { 'limits':
    config => {
                '*'       => { 'nofile'  => { soft => '2048'   , hard => '8192',   },},
                'oracle'  => { 'nofile'  => { soft => '65536'  , hard => '65536',  },
                                'nproc'  => { soft => '2048'   , hard => '16384',  },
                                'stack'  => { soft => '10240'  ,},},
                },
    use_hiera => false,
  }

  sysctl { 'kernel.msgmnb':                 ensure => 'present', permanent => 'yes', value => '65536',}
  sysctl { 'kernel.msgmax':                 ensure => 'present', permanent => 'yes', value => '65536',}
  sysctl { 'kernel.shmmax':                 ensure => 'present', permanent => 'yes', value => '2588483584',}
  sysctl { 'kernel.shmall':                 ensure => 'present', permanent => 'yes', value => '2097152',}
  sysctl { 'fs.file-max':                   ensure => 'present', permanent => 'yes', value => '6815744',}
  sysctl { 'net.ipv4.tcp_keepalive_time':   ensure => 'present', permanent => 'yes', value => '1800',}
  sysctl { 'net.ipv4.tcp_keepalive_intvl':  ensure => 'present', permanent => 'yes', value => '30',}
  sysctl { 'net.ipv4.tcp_keepalive_probes': ensure => 'present', permanent => 'yes', value => '5',}
  sysctl { 'net.ipv4.tcp_fin_timeout':      ensure => 'present', permanent => 'yes', value => '30',}
  sysctl { 'kernel.shmmni':                 ensure => 'present', permanent => 'yes', value => '4096', }
  sysctl { 'fs.aio-max-nr':                 ensure => 'present', permanent => 'yes', value => '1048576',}
  sysctl { 'kernel.sem':                    ensure => 'present', permanent => 'yes', value => '250 32000 100 128',}
  sysctl { 'net.ipv4.ip_local_port_range':  ensure => 'present', permanent => 'yes', value => '9000 65500',}
  sysctl { 'net.core.rmem_default':         ensure => 'present', permanent => 'yes', value => '262144',}
  sysctl { 'net.core.rmem_max':             ensure => 'present', permanent => 'yes', value => '4194304', }
  sysctl { 'net.core.wmem_default':         ensure => 'present', permanent => 'yes', value => '262144',}
  sysctl { 'net.core.wmem_max':             ensure => 'present', permanent => 'yes', value => '1048576',}

}
