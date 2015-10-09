class ossec::repo (
  $redhat_manage_epel = true
) {
  case $::osfamily {
    'Debian' : {
      case $::lsbdistcodename {
        /(lucid|precise|trusty)/: {
        
          apt::source { 'wazuh':
            ensure      => present,
            comment     => 'This is the WAZUH Ubuntu repository for Ossec',
            location    => 'http://ossec.wazuh.com/repos/apt/ubuntu',
            release     => $::lsbdistcodename,
            repos       => 'main',
            include_src => false,
            include_deb => true,
            key         => '9A1B1C65',
            key_source  => 'http://ossec.wazuh.com/repos/apt/conf/ossec-key.gpg.key',
          }
          ~>
          exec { 'update-apt-wazuh-repo':
            command     => '/usr/bin/apt-get update',
            refreshonly => true
          }

    }
        /^(jessie|wheezy)$/: {
          apt::source { 'wazuh':
            ensure      => present,
            comment     => 'This is the WAZUH Debian repository for Ossec',
            location    => 'http://ossec.wazuh.com/repos/apt/debian',
            release     => $::lsbdistcodename,
            repos       => 'main',
            include_src => false,
            include_deb => true,
            key         => '9A1B1C65',
            key_source  => 'http://ossec.wazuh.com/repos/apt/conf/ossec-key.gpg.key',
          }
          ~>
          exec { 'update-apt-alienvault-repo':
            command     => '/usr/bin/apt-get update',
            refreshonly => true
          }
        }
        default: { fail('This ossec module has not been tested on your distribution (or lsb package not installed)') }
      }
    }
    'Redhat' : {
      # Set up OSSEC rpm gpg key
      file { 'RPM-GPG-KEY.ossec.txt':
        path   => '/etc/pki/rpm-gpg/RPM-GPG-KEY.ossec.txt',
        source => 'puppet:///modules/ossec/RPM-GPG-KEY.ossec.txt',
        owner  => 'root',
        group  => 'root',
        mode   => '0664',
      }

      # Set up OSSEC repo
      yumrepo { 'ossec':
        descr      => 'WAZUH OSSEC Repository - www.wazuh.com',
        enabled    => true,
        gpgkey     => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY.ossec.txt',
        baseurl    => 'http://ossec.wazuh.com/el/$releasever/$basearch',
        priority   => 1,
        protect    => false,
        require    => [ File['RPM-GPG-KEY.ossec.txt'] ]
      }

      package { 'inotify-tools':
        ensure  => present
      }

      if $redhat_manage_epel {
        # Set up EPEL repo
        # NOTE: This relies on the 'epel' module referenced in metadata.json
        include epel

        Class['epel'] -> Package['inotify-tools']
      }
    }
    default: { fail('This ossec module has not been tested on your distribution') }
  }
}