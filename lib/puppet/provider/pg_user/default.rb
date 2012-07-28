require 'puppet/provider/pg_common'

Puppet::Type.type(:pg_user).provide(:default) do
  include Puppet::Provider::Postgresql

  desc "Manage users for a postgres database"

  def create
    psql query_for('CREATE')
  end

  def destroy
    pgsu('dropuser %s' % resource[:name])
  end

  def exists?
    output = psql("SELECT 1 FROM pg_roles WHERE rolname = '%s'" % resource[:name])
    return false unless output.first == "1\n"

    psql query_for('ALTER')
    return true
  end

  protected
    def query_for(action)
      "#{action} ROLE %s ENCRYPTED PASSWORD '%s' " \
      "%sCREATEDB %sINHERIT %sLOGIN %sCREATEROLE %sSUPERUSER" % [

        resource[:name],
        resource[:password],

        ('NO' if !resource[:createdb]  ),
        ('NO' if !resource[:inherit]   ),
        ('NO' if !resource[:login]     ),
        ('NO' if !resource[:createrole]),
        ('NO' if !resource[:superuser] )
      ]
    end

end
