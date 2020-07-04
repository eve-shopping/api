require "micrate"
require "pg"

Micrate::DB.connection_url = %(postgres://eve-shopping:#{File.read ENV["DB_PASSWORD_FILE"]}@db:5432/eve-shopping)
Micrate::Cli.run
