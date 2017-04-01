# Hiera backend for Noodle
Puppet::Functions.create_function(:noodle) do
  dispatch :noodle_lookup_key do
    param 'String[1]', :key
    param 'Hash[String[1],Any]', :options
    param 'Puppet::LookupContext', :context
  end

  def noodle_lookup_key(key,options,context)
    "7"
  end
end
