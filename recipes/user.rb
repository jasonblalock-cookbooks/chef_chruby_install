#
# Cookbook Name:: chruby_install
# Recipe:: user
#

::Chef::Recipe.send(:include, ChrubyInstall::Helpers)
::Chef::Recipe.send(:require, 'chef/util/file_edit')

include_recipe 'build-essential'
include_recipe 'chruby_install::_git'

install_chruby

log 'chruby_users' do
  message "Chruby users: #{node[:chruby_install][:users]}"
  level :info
end

node[:chruby_install][:users].each do |user, settings|
  log 'user' do
    message "User: #{user}\nPasswd: #{node['etc']['passwd'][user.to_s]}"
    level :info
  end
  
  user_info = node['etc']['passwd'][user.to_s]
  home = user_info['dir']

  settings_file = "#{home}/.chruby.sh"

  template settings_file do
    source "chruby.sh.erb"
    variables :settings => node[:chruby_install].merge(settings)
    owner user
    group user
    mode "0644"
  end

  config_line = "source #{settings_file}"

  ["#{home}/.bashrc", "#{home}/.zshrc"].each do |shell_config_file|
    if File.exists?(shell_config_file)
      fe = Chef::Util::FileEdit.new(shell_config_file)
      fe.insert_line_if_no_match(Regexp.new(Regexp.escape(config_line)), config_line)
      fe.write_file
    end
  end
end
