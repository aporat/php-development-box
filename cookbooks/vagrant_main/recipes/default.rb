node.set["apache"]["user"]  = "vagrant"
node.set["apache"]["group"] = "vagrant"

node.set['mysql']['server_root_password'] = "root"
node.set['mysql']['server_debian_password'] = "root"
node.set['mysql']['server_repl_password'] = "root"

node.set["app"]["php_timezone"] = "UTC"

node.set["apache"]["user"]  = "vagrant"
node.set["apache"]["group"] = "vagrant"

node.set["phpmyadmin"]["version"]  = "4.0.0"

node.set['mysql']['server_root_password'] = "root"
node.set['mysql']['old_passwords'] = 1

include_recipe "php54"

case node['platform_family']
  when "rhel", "fedora", "suse"
  
  when "debian"
    include_recipe "apt"
end

include_recipe "networking_basic"

include_recipe "apache2"
include_recipe "apache2::mod_php5"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_ssl"
include_recipe "mysql::server"
include_recipe "openssl"


case node['platform_family']
  when "rhel", "fedora", "suse"
  
  bash "disable_firewall" do
    only_if "chkconfig --list | grep iptables"
    code <<-EOH
      service iptables stop
      chkconfig iptables off
    EOH
  end

  # Vagrant has a speical kernel, which cannot be updated with yum
  execute "echo 'exclude=kernel*' >> /etc/yum.conf"
end

include_recipe "phpmyadmin"

phpmyadmin_db 'Dev DB' do
  host '127.0.0.1'
  port 3306
  username 'root'
  password ''
  hide_dbs %w{ information_schema mysql phpmyadmin performance_schema }
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


web_app "web_app" do
   docroot "/vagrant"
   template "webapp.conf.erb"
   server_name "wepapp.dev"
   server_aliases [node[:hostname], "wepapp.dev"]
   notifies :reload, resources(:service => "apache2"), :delayed
 end
