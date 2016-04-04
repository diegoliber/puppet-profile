class profile::oracle::se (

  $db_version = "12.1.0.2",
  $db_file    = "linuxamd64_12102_database_se2",

  $oraInventory_dir = "/oracle",
  $oracle_base_dir = "/oracle",
  $oracle_home_dir = "/oracle/product/12.1/db",

  $oracle_os_user = "oracle",
  $oracle_os_group = "dba",

  $oracle_download_dir = "/var/tmp/install",
  $oracle_source = "/vagrant",

  $oracle_database_name = 'cdb',
  $oracle_database_domain_name = 'example.com',
  $oracle_database_service_name = 'cdb.example.com',
  $oracle_database_host = 'dbcdb.example.com:1521',

  $oracle_database_file_dest = '/oracle/oradata',
  $oracle_database_recovery_dest = '/oracle/flash_recovery_area',

  $oracle_database_sys_password = 'Welcome01',
  $oracle_database_system_password = 'Welcome01',

  $memory_percentage = "50",
  $memory_total = "1000",

) {

  require profile::oracle::base

  oradb::installdb{ 'db_linux-x64':
      version                   => $db_version,
      file                      => $db_file,
      database_type             => 'SE',
      ora_inventory_dir         => $oraInventory_dir,
      oracle_base               => $oracle_base_dir,
      oracle_home               => $oracle_home_dir,
      user_base_dir             => '/home',
      user                      => $oracle_os_user,
      group                     => 'dba',
      group_install             => 'oinstall',
      group_oper                => 'oper',
      download_dir              => $oracle_download_dir,
      remote_file               => false,
      puppet_download_mnt_point => $oracle_source,
  }

  oradb::net{ 'config net8':
      oracle_home  => $oracle_home_dir,
      version      => $dbinstance_version,
      user         => $oracle_os_user,
      group        => 'dba',
      download_dir => $oracle_download_dir,
      db_port      => '1521', #optional
      require      => Oradb::Installdb['db_linux-x64'],
  }

  db_listener{ 'startlistener':
      ensure          => 'running',  # running|start|abort|stop
      oracle_base_dir => $oracle_base_dir,
      oracle_home_dir => $oracle_home_dir,
      os_user         => $oracle_os_user,
      require         => Oradb::Net['config net8'],
  }

  oradb::database{ 'oraDb':
      oracle_base               => $oracle_base_dir,
      oracle_home               => $oracle_home_dir,
      version                   => $dbinstance_version,
      user                      => $oracle_os_user,
      group                     => $oracle_os_group,
      download_dir              => $oracle_download_dir,
      action                    => 'create',
      db_name                   => $oracle_database_name,
      db_domain                 => $oracle_database_domain_name,
      sys_password              => $oracle_database_sys_password,
      system_password           => $oracle_database_system_password,
      character_set             => 'AL32UTF8',
      nationalcharacter_set     => 'UTF8',
      sample_schema             => 'TRUE',
      memory_percentage         => $memory_percentage,
      memory_total              => $memory_total,
      database_type             => 'MULTIPURPOSE',
      em_configuration          => 'NONE',
      data_file_destination     => $oracle_database_file_dest,
      recovery_area_destination => $oracle_database_recovery_dest,
      init_params               => {'open_cursors'        => '1000',
                                    'processes'           => '600',
                                    'job_queue_processes' => '4' },
      container_database        => false,
      require                   => Db_listener['startlistener'],
  }

  oradb::dbactions{ 'start oraDb':
      oracle_home             => $oracle_home_dir,
      user                    => $oracle_os_user,
      group                   => $oracle_os_group,
      action                  => 'start',
      db_name                 => $oracle_database_name,
      require                 => Oradb::Database['oraDb'],
  }

  oradb::autostartdatabase{ 'autostart oracle':
      oracle_home             => $oracle_home_dir,
      user                    => $oracle_os_user,
      db_name                 => $oracle_database_name,
      require                 => Oradb::Dbactions['start oraDb'],
  }

}
