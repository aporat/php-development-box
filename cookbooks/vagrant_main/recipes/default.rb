node.set["app"]["php_timezone"] = "UTC"

node.set["apache"]["user"]  = "vagrant"
node.set["apache"]["group"] = "vagrant"

node.set["phpmyadmin"]["version"]  = "4.0.0"

node.set['mysql']['server_root_password'] = "root"
node.set['mysql']['server']['packages'] = %w{mysql55-server}
node.set['mysql']['old_passwords'] = 1
node.set['mysql']['client']['packages'] = %w{mysql55}

node.set['php']['packages'] = ['php54w', 'php54w-devel', 'php54w-cli', 'php54w-snmp', 'php54w-soap', 'php54w-xml', 'php54w-xmlrpc', 'php54w-process', 'php54w-mysql55', 'php54w-pecl-memcache', 'php54w-pecl-apc', 'php54w-pear', 'php54w-pdo', 'php54w-gd', 'php54w-imap', 'php54w-mbstring']

node.set['yum']['exclude'] = "kernel*"

include_recipe "build-essential"
include_recipe "apache2::default"
include_recipe "apache2::mod_ssl"
include_recipe "apache2::mod_rewrite"
include_recipe "openssl::default"

# add the webtatic repository
yum_repository "webtatic" do
  repo_name "webtatic"
  description "webtatic Stable repo"
  url "http://repo.webtatic.com/yum/el6/x86_64/"
  key "RPM-GPG-KEY-webtatic-andy"
  action :add
end

yum_key "RPM-GPG-KEY-webtatic-andy" do
  url "http://repo.webtatic.com/yum/RPM-GPG-KEY-webtatic-andy"
  action :add
end

include_recipe "mysql::server"
include_recipe "php"
include_recipe "composer"

include_recipe "phpmyadmin::default"

phpmyadmin_db 'Dev DB' do
  host '127.0.0.1'
  port 3306
  username 'root'
  password ''
  hide_dbs %w{ information_schema mysql phpmyadmin performance_schema }
end

bash "disable_firewall" do
  only_if "chkconfig --list | grep iptables"
  code <<-EOH
    service iptables stop
    chkconfig iptables off
  EOH
end

directory "/etc/php.d" do
  owner "root"
  group "root"
  mode 0755
  action :create
end

template "/etc/php.d/webapp.ini" do
  source "php.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables({
    :php_timezone => node[:app][:php_timezone]
  })
end

# Vagrant has a speical kernel, which cannot be updated with yum
execute "echo 'exclude=kernel*' >> /etc/yum.conf"

web_app "web_app" do
   docroot "/vagrant"
   template "webapp.conf.erb"
   server_name "wepapp.dev"
   server_aliases [node[:hostname], "wepapp.dev"]
   notifies :reload, resources(:service => "apache2"), :delayed
 end

