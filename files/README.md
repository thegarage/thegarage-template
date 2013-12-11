### Wondering where to go from here?

`vagrant up --provision`

Or, you can separately do `vagrant up` and `vagrant provision`. Same thing, split into two.

That'll get your VM running. This also has your Rails server already started- just check [http://localhost:3000/](http://localhost:3000/). If you check it sometime during development and it's down, shell into this folder and execute `touch tmp/restart.txt` to restart it.

You're ready to get started.

If you're a designer, feel free to put new views inside of `/app/views/static`.

If you're a developer, you're good to do whatever you want. When you're ready to hit production, don't forget to add your new NewRelic license to the `.env` file.

## And don't forget to update this!
