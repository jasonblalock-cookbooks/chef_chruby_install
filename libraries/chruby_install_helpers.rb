module ChrubyInstall
  module Helpers
    def install_chruby
      cache_path = Chef::Config['file_cache_path']
      src_path = "#{cache_path}/chruby"

      execute "Install chruby" do
        cwd      src_path
        command  %{make install}

        action   :nothing

        not_if do
          ::File.exists?("/usr/local/bin/chruby-exec") && node[:chruby_install][:auto_upgrade] == false
        end
      end

      directory ::File.dirname(src_path) do
        recursive true
      end

      git src_path do
        repository  node[:chruby_install][:git_url]
        reference   node[:chruby_install][:git_ref]

        if node[:chruby_install][:auto_upgrade]
          action :sync
        else
          action :checkout
        end

        notifies :run, resources(:execute => "Install chruby"), :immediately
      end
    end
  end
end