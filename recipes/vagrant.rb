vagrant_git_ignore_template = <<-EOS

# Vagrant files
boxes/*
.vagrant
EOS

stage_two do
  say_wizard 'recipe stage_two'

  append_to_file '.gitignore', vagrant_git_ignore_template
  repo = 'https://raw.github.com/thegarage/thegarage-template/master/files/'
  copy_from_repo 'Vagrantfile', repo: repo

  recipes = %w(
    provisioning/rails_developer.yml
    provisioning/roles/core/tasks/main.yml
    provisioning/roles/gemrc/tasks/main.yml
    provisioning/roles/gemrc/files/gemrc
    provisioning/roles/jfredee.galaxy-rbenv-ruby/defaults/main.yml
    provisioning/roles/jfredee.galaxy-rbenv-ruby/meta/.galaxy_install_info
    provisioning/roles/jfredee.galaxy-rbenv-ruby/meta/main.yml
    provisioning/roles/jfredee.galaxy-rbenv-ruby/README.md
    provisioning/roles/jfredee.galaxy-rbenv-ruby/tasks
    provisioning/roles/jfredee.galaxy-rbenv-ruby/tasks/main.yml
    provisioning/roles/jfredee.galaxy-rbenv-ruby/tasks/rbenv-ruby-install.yml
    provisioning/roles/jfredee.galaxy-rbenv-ruby/tasks/rbenv.yml
    provisioning/roles/jfredee.galaxy-rbenv-ruby/templates/rbenv.sh.j2
    provisioning/roles/jfredee.galaxy-rbenv-ruby/vars/main.yml
    provisioning/roles/mailcatcher/tasks/main.yml
    provisioning/roles/mailcatcher/templates/mailcatcher.upstart.conf.j2
    provisioning/roles/mailcatcher/vars/main.yml
    provisioning/roles/nodejs/tasks/main.yml
    provisioning/roles/postgresql/files/pg_hba.conf
    provisioning/roles/postgresql/files/pgdg.list
    provisioning/roles/postgresql/handlers/main.yml
    provisioning/roles/postgresql/tasks/main.yml
    provisioning/roles/postgresql/vars/main.yml
    provisioning/roles/rails_setup/files/vm_rails_setup.sh
    provisioning/roles/rails_setup/tasks/main.yml
    provisioning/roles/ruby/tasks/main.yml
    provisioning/roles/ruby/templates/rbenv.sh.j2
    provisioning/roles/ruby/vars/main.yml
    provisioning/roles/set_locale/files/lang.sh
    provisioning/roles/set_locale/tasks/main.yml
  )
  recipes.each do |recipe|
    copy_from_repo recipe, repo: repo
  end

  ## Git
  git :add => '-A' if prefer :git, true
  git :commit => '-qm "rails_apps_composer: setup Vagrant"' if prefer :git, true

  system 'vagrant up'
end

__END__

name: vagrant
description: 'Add Vagrant configuration to your application'
author: wireframe
category: other
