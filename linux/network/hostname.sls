{%- from "linux/map.jinja" import network with context %}
{%- if network.enabled %}

{%- set osmajorrelease = grains['osmajorrelease'] %}

{%- if grains.os_family in ['Arch', 'Debian'] %}

linux_hostname_file:
  file.managed:
  - name: {{ network.hostname_file }}
  - source: salt://linux/files/hostname
  - template: jinja
  - user: root
  - group: root
  - mode: 644
  - watch_in:
    - cmd: linux_enforce_hostname

{%- elif grains.os_family == 'RedHat' %}
linux_hostname_file_rh:
  file.managed:
  - name: {{ network.hostname_file }}
  - source: salt://linux/files/rh/network
  - template: jinja
  - user: root
  - group: root
  - mode: 644
#  - watch_in:
#    - cmd: linux_enforce_hostname

linux_enforce_hostname:
  cmd.wait:
  - name: hostname {{ network.hostname }}
  - unless: test "$(hostname)" = "{{ network.hostname }}"

{%- if osmajorrelease in [7, 8] %}
set_hostname_cmd:
  cmd.run:
    - name: hostnamectl set-hostname {{ network.hostname }}

{%- endif %}
{%- endif %}

{#
linux_hostname_hosts:
  host.present:
  - ip: {{ grains.ip4_interfaces[network.get('default_interface', 'eth0')][0] }}
  - names:
    - {{ network.fqdn }}
    - {{ network.hostname }}
#}

{%- endif %}
