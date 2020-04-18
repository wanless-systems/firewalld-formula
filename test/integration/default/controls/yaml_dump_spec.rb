# frozen_string_literal: true

control 'firewalld `map.jinja` YAML dump' do
  title 'should contain the lines'

  yaml_dump = "---\n"
  yaml_dump += <<~YAML_DUMP.chomp
    AutomaticHelpers: system
    FirewallBackend: nftables
    FlushAllOnReload: 'yes'
    IndividualCalls: 'no'
    LogDenied: 'off'
    RFC3964_IPv4: 'yes'
    arch: amd64
    backend:
      manage: true
      pkg: nftables
    config: /etc/firewalld.conf
    default_zone: public
    direct:
      chain:
        MYCHAIN:
          ipv: ipv4
          table: raw
      rule:
        INTERNETACCESS:
          ipv: ipv4
          table: filter
          chain: FORWARD
          priority: '0'
          args: -i iintern -o iextern -s 192.168.1.0/24 -m conntrack --ctstate NEW,RELATED,ESTABLISHED
            -j ACCEPT
      passthrough:
        MYPASSTHROUGH:
          ipv: ipv4
          args: -t raw -A MYCHAIN -j DROP
    enabled: true
    ipset:
      manage: true
      pkg: ipset
    ipsets:
      fail2ban-ssh:
        short: fail2ban-ssh
        description: fail2ban-ssh ipset
        type: hash:ip
        options:
          maxelem:
          - 65536
          timeout:
          - 300
          hashsize:
          - 1024
        entries:
        - 10.0.0.1
      fail2ban-ssh-ipv6:
        short: fail2ban-ssh-ipv6
        description: fail2ban-ssh-ipv6 ipset
        type: hash:ip
        options:
          family:
          - inet6
          maxelem:
          - 65536
          timeout:
          - 300
          hashsize:
          - 1024
        entries:
        - 2a01::1
    package: firewalld
    service: firewalld
    services:
      sshcustom:
        short: sshcustom
        description: SSH on port 3232 and 5252. Secure Shell (SSH) is a protocol for logging
          into and executing commands on remote machines. It provides secure encrypted
          communications. If you plan on accessing your machine remotely via SSH over
          a firewalled interface, enable this option. You need the openssh-server package
          installed for this option to be useful.
        ports:
          tcp:
          - 3232
          - 5252
        modules:
        - some_module_to_load
        protocols:
        - igmp
        source_ports:
          tcp:
          - 21
        destinations:
          ipv4:
          - 224.0.0.251
          - 224.0.0.252
          ipv6:
          - ff02::fb
          - ff02::fc
      zabbixcustom:
        short: Zabbixcustom
        description: zabbix custom rule
        ports:
          tcp:
          - '10051'
      salt-minion:
        short: salt-minion
        description: salt-minion
        ports:
          tcp:
          - '8000'
    zones:
      public:
        short: Public
        description: For use in public areas. You do not trust the other computers on
          networks to not harm your computer. Only selected incoming connections are accepted.
        services:
        - http
        - https
        - ssh
        - salt-minion
        other_services:
        - zabbixcustom
        protocols:
        - igmp
        rich_rules:
        - family: ipv4
          source:
            address: 8.8.8.8/24
          accept: true
        - family: ipv4
          ipset:
            name: fail2ban-ssh
          reject:
            type: icmp-port-unreachable
        ports:
        - comment: zabbix-agent
          port: 10050
          protocol: tcp
        - comment: bacula-client
          port: 9102
          protocol: tcp
        - comment: vsftpd
          port: 21
          protocol: tcp
        source_ports:
        - comment: something
          port: 2222
          protocol: tcp
        - comment: something_else
          port: 4444
          protocol: tcp
      rich_public:
        short: rich_public
        description: Example
        rich_rules:
          ssh-csg:
            accept: true
            ipsets:
            - fail2ban-ssh
            - other-ipset
            services:
            - ssh
  YAML_DUMP

  describe file('/tmp/salt_yaml_dump.yaml') do
    its('content') { should include yaml_dump }
  end
end
