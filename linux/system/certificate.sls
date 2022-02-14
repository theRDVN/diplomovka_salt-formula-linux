{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- if system.ca_certificates is defined %}

linux_system_ca_certificates:
  pkg.installed:
    - name: ca-certificates

{%- if grains.os_family == 'Debian' %}

{%- if system.ca_certificates is mapping %}

{%- for name, cert in system.ca_certificates.items() %}
{{ system.ca_certs_dir }}/{{ name }}.crt:
  file.managed:
  - contents_pillar: "linux:system:ca_certificates:{{ name }}"
  - watch_in:
    - cmd: update_certificates
  - require:
    - pkg: linux_system_ca_certificates
{%- endfor %}

{%- else %}
{#- salt-pki way #}

{%- for certificate in system.ca_certificates %}
{{ system.ca_certs_dir }}/{{ certificate }}.crt:
  file.managed:
  - source: salt://pki/{{ certificate }}/{{ certificate }}-chain.cert.pem
  - watch_in:
    - cmd: update_certificates
  - require:
    - pkg: linux_system_ca_certificates
{%- endfor %}

{%- endif %}

update_certificates:
  cmd.wait:
  - name: update-ca-certificates

{%- elif grains.os_family == 'RedHat' %}

{%- for certificate in system.ca_certificates %}
copy_cert_{{ certificate }}:
  file.recurse:
    - name: {{ system.ca_certs_dir }}
    - source: {{ system.ca_certs_source }}
    - include_pat: E@{{ certificate }}
    - watch_in:
      - cmd: update_certificates_rh
    - require:
      - pkg: linux_system_ca_certificates
{% endfor %}

update_certificates_rh:
  cmd.wait:
  - name: update-ca-trust; update-ca-trust enable; update-ca-trust force-enable

{%- endif %}

{% endif %}

{%- endif %}
