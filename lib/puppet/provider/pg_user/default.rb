require 'puppet/provider/pg_common'

Puppet::Type.type(:pg_user).provide(:default) do
  include Puppet::Provider::Postgresql

  desc "Manage users for a postgres database"

  def create
    query =
      "CREATE ROLE %s ENCRYPTED PASSWORD '%s' " \
      "%sCREATEDB %sINHERIT %sLOGIN %sCREATEROLE %sSUPERUSER" % [

        resource[:name],
        resource[:password],

        ('NO' if !resource[:createdb]  ),
        ('NO' if !resource[:inherit]   ),
        ('NO' if !resource[:login]     ),
        ('NO' if !resource[:createrole]),
        ('NO' if !resource[:superuser] )
      ]

    psql query
  end

  def destroy
    pgsu('dropuser %s' % resource[:name])
  end

  def exists?
    output = psql("select 1 from pg_roles where rolname = '%s'" % resource[:name])
    output.first == "1\n"
  end

end
