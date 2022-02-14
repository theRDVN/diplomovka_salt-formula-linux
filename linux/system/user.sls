{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- for name, user in system.user.items() %}

{%- if user.enabled %}

system_user_{{ name }}:
  user.present:
  - name: {{ name }}
  - home: {{ user.home }}
  {%- if user.password is defined %}
  - password: {{ user.password }}
  - enforce_password: true
  {%- endif %}
  {%- if user.groups is defined %}
  - groups: {{ user.groups }}
  {%- endif %}
  {%- if user.gid is defined and user.gid %}
  - gid: {{ user.gid }}
  {%- endif %}
  {%- if user.system is defined and user.system %}
  - system: True
  {%- else %}
  - shell: {{ user.get('shell', '/bin/bash') }}
  {%- endif %}
  {%- if user.uid is defined and user.uid %}
  - uid: {{ user.uid }}
  {%- endif %}

system_user_home_{{ user.home }}:
  file.directory:
  - name: {{ user.home }}
  - user: {{ name }}
  - mode: 700
  - makedirs: true
  - require:
    - user: system_user_{{ name }}

{%- if user.get('sudo', False) %}

/etc/sudoers.d/90-salt-user-{{ name|replace('.', '-') }}:
  file.managed:
  - source: salt://linux/files/sudoer
  - template: jinja
  - user: root
  - group: root
  - mode: 440
  - defaults:
    user_name: {{ name }}
  - require:
    - user: system_user_{{ name }}
  - check_cmd: /usr/sbin/visudo -c -f

{%- endif %}

{%- else %}

system_user_{{ name }}:
  user.absent:
  - name: {{ name }}

system_user_home_{{ user.home }}:
  file.absent:
  - name: {{ user.home }}

/etc/sudoers.d/90-salt-user-{{ name|replace('.', '-') }}:
  file.absent

{%- endif %}

{%- endfor %}

{%- endif %}
