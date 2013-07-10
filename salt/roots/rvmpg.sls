rvm-deps:
  pkg:
    - installed
    - groups:
      - "development tools"
    - pkgs:
      - gcc-c++
      - patch
      - readline
      - readline-devel
      - zlib
      - zlib-devel
      - libyaml-devel
      - libffi-devel
      - openssl-devel
      - make
      - bzip2
      - autoconf
      - automake
      - libtool
      - bison

ruby-2.0.0:
  rvm.installed:
    - default: True
    - require:
      - pkg: rvm-deps

mygemset:
  rvm:
    - gemset_present
    - ruby: ruby-2.0.0
    - require:
      - rvm: ruby-2.0.0

pgdevel:
  pkg.installed:
    - name: postgresql92-devel

postgres-repo:
  pkg.installed:
    - sources:
      - pgdg-centos92: http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/pgdg-centos92-9.2-6.noarch.rpm

postgresql-9.2:
  pkg.installed:
    - name: postgresql92-server
    - require:
      - pkg: postgres-repo
  service.running:
    - enabled: True
    - require:
      - cmd: pghba

postgresql-first-run-init:
  cmd.run:
    - cwd: /
    - user: root
    - name: service postgresql-9.2 initdb
    - unless: stat /var/lib/pgsql/9.2/data/postgresql.conf
    - require:
      - pkg: postgresql-9.2

pghba:
  cmd.run:
    - user: root
    - name: sed 's/ident/trust/' < /var/lib/pgsql/9.2/data/pg_hba.conf > /var/lib/pgsql/9.2/data/temp && mv /var/lib/pgsql/9.2/data/temp /var/lib/pgsql/9.2/data/pg_hba.conf
    - require:
      - cmd: postgresql-first-run-init

bundle:
  cmd.run:
    - name: rvmsudo gem install bundler && rvmsudo gem install pg -- --with-pg-config=/usr/pgsql-9.2/bin/pg_config && rvmsudo bundle install
    - cwd: /vagrant
    - user: vagrant
    - require:
      - pkg: pgdevel
      - rvm: ruby-2.0.0
      - service: postgresql-9.2

createdb:
  cmd.run:
    - user: vagrant
    - cwd: /vagrant
    - name: rake db:create && rake db:migrate
    - require:
      - service: postgresql-9.2
      - cmd: bundle

iptables:
  service.dead

passenger-deps:
  pkg.installed:
    - pkgs:
      - pcre-devel
      - libcurl-devel
      - libxml2-devel
      - libxslt-devel
    - user: vagrant