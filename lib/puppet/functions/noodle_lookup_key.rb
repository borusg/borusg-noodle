Puppet::Functions.create_function(:noodle_lookup_key) do

  require '/usr/local/noodle/lib/noodle/client.rb'

  dispatch :noodle_lookup_key do
    param 'Variant[String, Numeric]', :key
    param 'Hash', :options
    param 'Puppet::LookupContext', :context
  end

  def noodle_lookup_key(key,options,context)
    # Ahem, we have no lookup_options (yet)
    context.not_found if key == 'lookup_options'

    value = Noodle.paramvalue(options['hostname'],key)
    context.not_found if value.nil? or value.empty?
    return value
  end
end

