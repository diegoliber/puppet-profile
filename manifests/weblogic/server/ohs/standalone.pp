class profile::weblogic::server::ohs::standalone (
  $domain_name,
  $nodemanager_address,

  #duplicated
  $os_user              = 'oracle',
  $os_group             = 'sdba',

  $nodemanager_user     = 'weblogic',
  $nodemanager_password = 'weblogic1',
  $download_dir         = '/var/tmp/install',
  $ohs_home             = '/opt/app/oracle/middleware12c/ohs',
  $mw_home              = '/opt/app/oracle/middleware12c',
  $wls_domains          = '/opt/app/oracle/middleware12c/user_projects/domains',
  $oracle_home          = '/opt/app/oracle',

  $version              = '1212',
  $install_source       = '/vagrant',
  $installer            = 'ofm_ohs_linux_12.1.2.0.0_64_disk1_1of1.zip',

  $java_home            = '/usr/java/latest', #?

  $nodemanager_port     = 5556,
  $log_output           = true,

  $listen_address       = '192.168.50.30',
  $listen_port          = '7777',
  $ssl_listen_port      = '4443',
) {

  $server_name = 'ohs1'
  $domain_dir = "${domains_dir}/${domain_name}"
  $oracle_inventory_dir = '/opt/oraInventory'

  contain profile::weblogic::base
  contain orawls::urandomfix

  Class['profile::weblogic::base'] ->

  Class['orawls::urandomfix'] ->

  # Diretório base do OHS (a instalação espera que o usuário tenha permissão de escrita nesta pasta).
  file { '/opt':
    ensure => directory,
    owner  => $os_user,
    group  => $os_group,
  } ->

  # Se tentarmos criar a pasta do inventário no caminho onde a aplicação é instalada, acabamos criando a pasta /opt/app/oracle.
  # Ao criar essa pasta uma parte do módulo acaba "quebrando" porque o recurso já foi definido... Isso deve mexer com alguma dependência
  # entre os recursos e tal. (A instalação espera que essa pasta já exista.)
  file { $oracle_inventory_dir:
    ensure => directory,
    owner  => $os_user,
    group  => $os_group,
  } ->

  orawls::fmw { 'ohs standalone':
    fmw_product          => 'web',
    fmw_file1            => $installer,
    remote_file          => false,
    log_output           => $log_output,
    version              => $version,
    weblogic_home_dir    => $ohs_home, # XXX: esse nome do parâmetro não é lá muito legal
    middleware_home_dir  => $mw_home,
    oracle_base_home_dir => $oracle_home,
    oracle_home_dir      => $oracle_home,
    jdk_home_dir         => $java_home,
    os_user              => $os_user,
    os_group             => $os_group,
    download_dir         => $download_dir,
    source               => $install_source,

    # parametros novos
    oracle_inventory_dir => $oracle_inventory_dir,
    ohs_mode             => 'standalone',
  } ->

  orawls::domain { "ohs domain ${domain_name}":
    wls_domains_dir                => $wls_domains,
    wls_apps_dir                   => $wls_apps,
    version                        => $version,
    download_dir                   => $download_dir,
    os_user                        => $os_user,
    os_group                       => $os_group,
    jdk_home_dir                   => $java_home,
    weblogic_home_dir              => $ohs_home, # XXX: esse nome do parâmetro não é lá muito legal
    middleware_home_dir            => $mw_home,
    domain_name                    => $domain_name,
    domain_template                => 'ohs_standalone',
    development_mode               => false,
    create_rcu                     => false,
    webtier_enabled                => false,
    nodemanager_address            => $nodemanager_address, # XXX acho que esse parâmetro é usado apenas em alguns templates (mas dá erro se tirar daqui porque ele tenta ir no hiera). Além disso, não coloquei a configuração do endereço do node manager no domain.py.erb... deveria?
    nodemanager_username           => $nodemanager_user,
    nodemanager_password           => $nodemanager_password,
    adminserver_address            => '127.0.0.1',
    ohs_standalone_listen_address  => $listen_address,
    ohs_standalone_listen_port     => $listen_port,
    ohs_standalone_ssl_listen_port => $ssl_listen_port,
    log_output                     => $log_output,
    weblogic_password              => '', # XXX desnecessário, mas dá erro se tirar por conta da chamada ao hiera sem valor padrão. pensar em como tratar isso.
  } ->

  orawls::nodemanager { "ohs nodemanager at ${nodemanager_address}":
    domain_name         => $domain_name,
    wls_domains_dir     => $wls_domains,
    version             => $version,
    download_dir        => $download_dir,
    os_user             => $os_user,
    os_group            => $os_group,
    jdk_home_dir        => $java_home,
    weblogic_home_dir   => $ohs_home, # XXX: esse nome do parâmetro não é lá muito legal
    middleware_home_dir => $mw_home,
    nodemanager_port    => $nodemanager_port,
    log_output          => $log_output,
    ohs_standalone     => true,
  } ->

  orawls::control { "start ohs ${domain_name}":
    wls_domains_dir     => $wls_domains,
    nodemanager_port    => $nodemanager_port,
    download_dir        => $download_dir,
    os_user             => $os_user,
    os_group            => $os_group,
    jdk_home_dir        => $java_home,
    weblogic_home_dir   => $ohs_home, # XXX: esse nome do parâmetro não é lá muito legal
    middleware_home_dir => $mw_home,
    domain_name         => $domain_name,
    server_type         => 'ohs_standalone',
    target              => 'Server',
    server              => $server_name,
    custom_trust        => false,
    action              => 'start',
    log_output          => $log_output,
    weblogic_user       => $nodemanager_user, # XXX: eu deveria criar um parâmetro nodemanager_user lá no orawls::control?
    weblogic_password   => $nodemanager_password, # XXX: eu deveria criar um parâmetro nodemanager_password lá no orawls::control?
  }

}
