def hetzner_init
  if $conf[:hetzner] && $conf[:hetzner][:user]
    h = Hetzner::API.new($conf[:hetzner][:user], $conf[:hetzner][:password])

    isp_id = 'hetzner'

    baremetal_isps[isp_id] = Class.new do
      define_singleton_method :scan do |state|
        target_state = {}

        hetzner_servers = h.servers?
        puts "#{hetzner_servers.length} servers at Hetzner"
        hetzner_servers.each do |e|
          print '.'
          s=e['server']
          tokens = s['dc'].scan(/(\w+)(\d)/)

          host = baremetal_by_id(isp_id, s['server_number'], state)
          host[:isp][:info] = s['product']
          host[:ipv4] = s['server_ip']

          naming_convention =  "#{s['product']}-.#{tokens[1][0]}#{tokens[0][1]}#{tokens[1][1]}.#{tokens[0][0]}".downcase

          target_state[baremetal_unique_id(naming_convention, host, target_state)] = host
        end
        puts ''

        target_state
      end
    end
  end
end