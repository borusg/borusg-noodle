Puppet::Functions.create_function(:noodle_lookup_key) do

  require '/usr/local/noodle/lib/noodle/client.rb'

  dispatch :noodle_lookup_key do
    param 'Variant[String, Numeric]', :key
    param 'Hash', :options
    param 'Puppet::LookupContext', :context
  end

  def noodle_lookup_key(key,options,context)
    # TODO: Why is key always 'lookup_key' instead of something like 'ntp_servers'?!?
    # For now force looking up the 'site' param below.
    # puts "key is #{key}."
    #
    # TODO: hostname should really be FQDN:
    value = Noodle.paramvalue(options['hostname'],'site')
    context.not_found if value.nil? or value.empty?
    # TODO: This fails unless it's a hash? Grok that.
    return {'value' => value}
  end
end

