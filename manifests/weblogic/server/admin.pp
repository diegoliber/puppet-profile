class profile::weblogic::server::admin(
  $admin_server_address,
  $nodemanager_address,
  $domain_name,

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


  $server                            = 'AdminServer'
  $server_type                       = 'admin'

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
  orawls::domain { $domain_name:
    wls_domains_dir     => $wls_domains,
    wls_apps_dir        => $wls_apps,
    version             => $version,
    download_dir        => $download_dir,
    os_user             => $os_user,
    os_group            => $os_group,
    domain_name         => $domain_name,
    weblogic_password   => $wl_password,
    jdk_home_dir        => $java_home,
    weblogic_home_dir   => $wl_home,
    middleware_home_dir => $mw_home,
    domain_template     => 'standard',
    development_mode    => false,
    log_output          => $log_output,
  }
  ->
  orawls::packdomain { $domain_name:
    version             => $version,
    wls_domains_dir     => $wls_domains,
    os_user             => $os_user,
    os_group            => $os_group,
    download_dir        => $download_dir,
    jdk_home_dir        => $java_home,
    weblogic_home_dir   => $wl_home,
    middleware_home_dir => $mw_home,
    log_output          => $log_output,
    domain_name         => $domain_name,
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
  wls_server { 'AdminServer':
    ensure            => 'present',
    machine           => "m_${::hostname}",
    listenaddress     => $admin_server_address,
    listenport        => $admin_server_port,
    listenportenabled => '1',
  }
  ->
  wls_cluster { "WebCluster":
    ensure           => 'present',
    #unicastbroadcastchannel => "Channel-Cluster",
    messagingmode    => 'unicast',
    migrationbasis   => 'database',
  }
  ->
  class { 'orautils':
    os_oracle_home     => $oracle_home,
    ora_inventory      => "${oracle_home}/oraInventory",
    os_domain_type     => 'admin',
    os_log_folder      => '/var/log/weblogic',
    os_download_folder => $download_dir,
    os_mdw_home        => $mw_home,
    os_wl_home         => $wl_home,
    ora_user           => $os_user,
    ora_group          => $os_group,
    node_mgr_port      => $nodemanager_port,
    wls_user           => $wl_user,
    jsse_enabled       => false,
    os_domain          => $domain_name,
    os_domain_path     => "${wls_domains}/${domain_name}",
    node_mgr_path      => "${wls_domains}/${domain_name}/bin",
    node_mgr_address   => $admin_server_address,
    wls_password       => $wl_password,
    wls_adminserver    => $server,
  }

}
