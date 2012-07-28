require 'puppet/provider/pg_common'

Puppet::Type.type(:pg_database).provide(:default) do
  include Puppet::Provider::Postgresql

  desc "Manage databases for a postgres database"

  def create
    pgsu("createdb -T %s -E %s -l %s -O %s %s" % [
      resource[:template],
      resource[:encoding],
      resource[:locale],
      resource[:owner],
      resource[:name]
    ])
  end

  def destroy
    pgsu("dropdb %s" % resource[:name])
  end

  def exists?
    output = psql("SELECT 1 FROM pg_database WHERE datname = '%s'" % @resource.value(:name))
    output.first == "1\n"
  end

end
