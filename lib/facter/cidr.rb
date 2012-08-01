# Returns the current netmask as CIDR format
#
require 'ipaddr'

module Ifad
  module Puppet
    def self.cidr_of(mask)
      bits, ip = 32, IPAddr.new(mask).to_i

      while ip & 1 == 0
        ip >>= 1
        bits -= 1
      end

      bits.to_s
    end
  end
end

Facter.value('interfaces').split(',').each do |interface|

  Facter.add("cidrmask_#{interface}") do
    setcode do
      mask = Facter.value("netmask_#{interface}")
      Ifad::Puppet.cidr_of(mask)
    end
  end

end

Facter.add('cidrmask') do
  setcode do
    Ifad::Puppet.cidr_of Facter.value('netmask')
  end
end
