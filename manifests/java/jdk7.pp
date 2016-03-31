class profile::java::jdk7(
  $source_path = '/vagrant'
) {

  $remove = [ "java-1.7.0-openjdk.x86_64", "java-1.6.0-openjdk.x86_64" ]

  package { $remove:
    ensure  => absent,
  }

  include jdk7

  jdk7::install7 { 'jdk1.7.0_79':
      #java_homes
      version                    => "7u79" ,
      full_version               => "jdk1.7.0_79",
      alternatives_priority      => 18000,
      x64                        => true,
      download_dir               => "/var/tmp/install",
      urandom_java_fix           => true,
      rsa_key_size_fix           => true,
      source_path                => $source_path,
  }
}
