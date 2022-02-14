{%- from "linux/map.jinja" import network with context %}
{%- if network.enabled %}

{%- if grains.os_family == 'RedHat' %}
remove_immutable_flag:
  cmd.run:
    - name: chattr -i /etc/resolv.conf
{%- endif %}

/etc/resolv.conf:
  file.managed:
  - source: salt://linux/files/resolv.conf
  - mode: 644
  - template: jinja

{%- if grains.os_family == 'Debian' %}
linux_resolvconf_disable:
  cmd.run:
  - name: resolvconf --disable-updates
  - onlyif: resolvconf --updates-are-enabled
{%- endif %}

{%- if grains.os_family == 'RedHat' %}
add_immutable_flag:
  cmd.run:
    - name: chattr +i /etc/resolv.conf
{%- endif %}

{%- endif %}
