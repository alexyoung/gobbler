class Settings
  CONFIG_FILE = File.dirname(__FILE__) / '..' / 'config.yml'

  def self.[](key)
    @@config ||= YAML.load(File.open(CONFIG_FILE))
    @@config[key]
  end
end
