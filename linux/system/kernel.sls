{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- if system.kernel is defined %}

{%- if system.kernel.isolcpu is defined %}

include:
  - linux.system.grub

/etc/default/grub.d/90-isolcpu.cfg:
  file.managed:
    - contents: 'GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT isolcpus={{ system.kernel.isolcpu }}"'
    - require:
      - file: grub_d_directory
    - watch_in:
      - cmd: grub_update

{%- endif %}

{%- if system.kernel.version is defined %}

linux_kernel_package:
  pkg.installed:
  - pkgs:
    - linux-image-{{ system.kernel.version }}-{{ system.kernel.type|default('generic') }}
    {%- if system.kernel.get('headers', False) %}
    - linux-headers-{{ system.kernel.version }}-{{ system.kernel.type|default('generic') }}
    {%- endif %}
    {%- if system.kernel.get('extra', False) %}
    - linux-image-extra-{{ system.kernel.version }}-{{ system.kernel.type|default('generic') }}
    {%- endif %}
  - refresh: true

# Not very Salt-ish.. :-(
linux_kernel_old_absent:
  cmd.wait:
  - name: "apt-get purge -y $(dpkg -l '*linux-image-[0-9]*' '*linux-headers-[0-9]*' '*linux-image-extra-[0-9]*' | grep -E '^ii' | awk '{print $2}' | grep -v '{{ system.kernel.version }}')"
  - watch:
    - pkg: linux_kernel_package

{%- endif %}


{%- for module in system.kernel.get('modules', []) %}

linux_kernel_module_{{ module }}:
  kmod.present:
    - name: {{ module }}
    - persist: true

{%- endfor %}

{%- for sysctl_name, sysctl_value in system.kernel.get('sysctl', {}).items() %}

linux_kernel_{{ sysctl_name }}:
  sysctl.present:
  - name: {{ sysctl_name }}
  - value: {{ sysctl_value }}

{%- endfor %}

{%- endif %}

{%- endif %}
