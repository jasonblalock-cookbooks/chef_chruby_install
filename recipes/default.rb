#
# Cookbook Name:: chruby_install
# Recipe:: default
#

::Chef::Recipe.send(:include, ChrubyInstall::Helpers)

include_recipe 'build-essential'
include_recipe 'chruby_install::_git'

install_chruby

directory "/etc/profile.d" do
  recursive true
end

template "/etc/profile.d/chruby.sh" do
  source "chruby.sh.erb"
  variables :settings => node[:chruby_install]
  mode "0644"
end
