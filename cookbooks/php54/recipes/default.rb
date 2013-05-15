case node['platform_family']
  when "rhel", "fedora", "suse"
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
  
  node.set['yum']['exclude'] = "kernel*"
  node.set['php']['packages'] = ['php54w', 'php54w-devel', 'php54w-cli', 'php54w-snmp', 'php54w-soap', 'php54w-xml', 'php54w-xmlrpc', 'php54w-process', 'php54w-mysql55', 'php54w-pecl-memcache', 'php54w-pecl-apc', 'php54w-pear', 'php54w-pdo', 'php54w-gd', 'php54w-imap', 'php54w-mbstring']
  node.set['mysql']['server']['packages'] = %w{mysql55-server}
  node.set['mysql']['client']['packages'] = %w{mysql55}
  
  include_recipe "mysql::server"
  
  when "debian"
    include_recipe "apt"
	apt_repository "dotdeb-php54" do
		uri node['dotdeb']['uri']
		distribution "#{node['dotdeb']['distribution']}-php54"
		components ['all']
		key "http://www.dotdeb.org/dotdeb.gpg"
		action :add
	end
	execute "update apt sources" do
		command "apt-get update"
		action :run
	end
  end

include_recipe 'php'