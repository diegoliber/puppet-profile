class profile::weblogic::base {

  contain profile::java::jdk7
  contain profile::weblogic::base::os
  contain profile::weblogic::base::ssh

  Class['profile::java::jdk7'] ->
      Class['profile::weblogic::base::os'] ->
        Class['profile::weblogic::base::ssh']

}
