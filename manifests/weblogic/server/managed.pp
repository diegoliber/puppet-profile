class profile::weblogic::server::managed(
  $admin_server_address,
  $nodemanager_address,
  $domain_name,
  $instance_number,
  $cluster                           = undef,

  $os_user                           = 'oracle',
  $os_group                          = 'sdba',

  $wl_user                           = 'weblogic',
  $wl_password                       = 'weblogic1',
  $download_dir                      = '/var/tmp/install',
  $wl_home                           = '/opt/app/oracle/middleware12c/wlserver',
  $mw_home                           = '/opt/app/oracle/middleware12c',
  $wls_domains                       = '/opt/app/oracle/wlsdomains/domains',
  $wls_apps                          = '/opt/app/oracle/wlsdomains/applications',
  $oracle_home                       = '/opt/app/oracle',

  $version                           = 1213,
  $install_source                    = '/vagrant',
  $installer                         = 'fmw_12.1.3.0.0_wls.jar',

  $java_home                         = '/usr/java/latest',

  $admin_server_port                 = 7001,
  $nodemanager_port                  = 5556,
  $log_output                        = true) {

  $server                            = "ManagedServer${instance_number}"
  $server_type                       = 'managed'


  contain profile::weblogic::base
  contain orawls::urandomfix

  Class['profile::weblogic::base'] ->
  Class['orawls::urandomfix'] ->

  class {'orawls::weblogic':
    version              => $version,
    filename             => $installer,
    weblogic_home_dir    => $wl_home,
    middleware_home_dir  => $mw_home,
    log_output           => $log_outpupt,
    jdk_home_dir         => $java_home,
    oracle_base_home_dir => $oracle_home,
    os_user              => $os_user,
    os_group             => $os_group,
    download_dir         => $download_dir,
    source               => $install_source,
    remote_file          => false,
    wls_domains_dir      => $wls_domains,
    wls_apps_dir         => $wls_apps,
  }
  ->
  orawls::copydomain { "copy ${domain_name}":
   version             => $version,
   middleware_home_dir => $mw_home,
   weblogic_home_dir   => $wl_home,
   jdk_home_dir        => $java_home,
   wls_domains_dir     => $wls_domains,
   wls_apps_dir        => $wls_apps,
   domain_name         => $domain_name,
   adminserver_address => $admin_server_address,
   adminserver_port    => $admin_server_port,
   weblogic_user       => $wl_user,
   weblogic_password   => $wl_password,
   os_user             => $os_user,
   os_group            => $os_group,
   download_dir        => $download_dir,
   log_output          => true,
  }
  ->
  orawls::nodemanager { "nodemanager ${server}":
    wls_domains_dir     => $wls_domains,
    version             => $version,
    download_dir        => $download_dir,
    os_user             => $os_user,
    os_group            => $os_group,
    domain_name         => $domain_name,
    jdk_home_dir        => $java_home,
    weblogic_home_dir   => $wl_home,
    middleware_home_dir => $mw_home,
    log_output          => $log_output,
    nodemanager_port    => $nodemanager_port,
  }
  ->
  wls_setting { 'default':
    user              => $os_user,
    weblogic_home_dir => $wl_home,
    connect_url       => "t3://${admin_server_address}:${admin_server_port}",
    weblogic_user     => $wl_user,
    weblogic_password => $wl_password,
  }
  ->
  wls_machine { "m_${::hostname}":
    ensure        => 'present',
    listenaddress => $nodemanager_address,
    listenport    => $nodemanager_port,
    machinetype   => 'UnixMachine',
    nmtype        => 'SSL',
  }
  ->
  wls_server { $server:
    ensure            => 'present',
    machine           => "m_${::hostname}",
    listenaddress     => $nodemanager_address,
    listenport        => 7001,
    listenportenabled => '1',
    cluster           => $cluster,
    arguments         => '',
  }
  ->
  wls_server_channel { "${server}:ReplicationChannel":
    ensure => 'present',
    enabled => '1',
    httpenabled => '1',
    listenaddress => $nodemanager_address,
    listenport => '8003',
    outboundenabled => '0',
    protocol => 'cluster-broadcast',
    publicaddress => $nodemanager_address,
    tunnelingenabled => '0',
  }
  ~>
  wls_adminserver{"${domain_name}/AdminServer":
    ensure              => running,
    refreshonly         => true,
    server_name         => 'AdminServer',
    domain_name         => $domain_name,
    domain_path         => "${wls_domains}/${domain_name}",
    os_user             => $os_user,
    nodemanager_address => $admin_server_address,
    nodemanager_port    => $nodemanager_port,
    weblogic_user       => $wl_user,
    weblogic_password   => $wl_password,
    weblogic_home_dir   => $wl_home,
  }
  ->
  orawls::control { "start ${server}":
    wls_domains_dir     => $wls_domains,
    adminserver_address => $admin_server_address,
    nodemanager_port    => $nodemanager_port,
    download_dir        => $download_dir,
    os_user             => $os_user,
    os_group            => $os_group,
    jdk_home_dir        => $java_home,
    weblogic_home_dir   => $wl_home,
    middleware_home_dir => $mw_home,
    weblogic_password   => $wl_password,
    domain_name         => $domain_name,
    target              => 'Server',
    server_type         => $server_type,
    server              => $server,
    action              => 'start',
    log_output          => $log_output,
  }


}
