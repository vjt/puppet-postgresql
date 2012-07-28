module Puppet::Provider::Postgresql
  def self.included(base)
    base.instance_eval do
      optional_commands :su => 'su'
    end

    protected
      def pgsu(command)
        su('-', 'postgres', '-c', command)
      end

      def psql(query)
	pgsu(%[ psql --quiet -A -t -c "#{query}" ])
      end
  end
end
