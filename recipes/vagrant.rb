gem 'guard-sheller', group: :ct

append_to_file '.gitignore', get_file_partial(:vagrant, '.gitignore')
get_file 'Vagrantfile'
get_file 'config/database.yml'

get_file 'bin/restart'
chmod 'bin/restart', 0755

append_to_file 'Guardfile', get_file_partial(:vagrant, 'Guardfile')

# ruby script to get list of all necessary provisioning files
# Dir.glob('files/provisioning/**/*').each { |f| puts f.gsub(/^files\//, '') unless File.directory?(f) }
recipes = %w(
  provisioning/rails_developer.yml
  provisioning/roles/core/tasks/main.yml
  provisioning/roles/gemrc/files/gemrc
  provisioning/roles/gemrc/tasks/main.yml
  provisioning/roles/nodejs/tasks/main.yml
  provisioning/roles/phantomjs/tasks/main.yml
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
  get_file recipe
end

commit_changes 'Setup Vagrant virtualized environment'

stage_two do
  run 'bundle package'

  commit_changes 'package gems'
  run 'vagrant up'
end

stage_three do
  run 'open http://localhost:3000'
end

__END__

name: vagrant
description: 'Add Vagrant configuration to your application'
author: wireframe
category: other
