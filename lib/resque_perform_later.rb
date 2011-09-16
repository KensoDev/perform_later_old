class ResquePerformLater
  APP_ROOT = File.expand_path((defined?(Rails) && Rails.root.to_s.length > 0) ? Rails.root : ".") unless defined?(APP_ROOT)
  DEFAULT_CONFIG_PATH = File.join(APP_ROOT, 'config', 'resque_perform_later.yml')
  DEFAULT_CONFIG = {
    'enabled' => true
  }

  # inspired by DelayedJob

  CLASS_STRING_FORMAT = /^CLASS\:([A-Z][\w\:]+)$/
  AR_STRING_FORMAT    = /^AR\:([A-Z][\w\:]+)\:(\d+)$/
  YAML_STRING_FORMAT  = /\A---/

  def self.args_to_resque(args)
    args = args.map { |o|
      case o
        when ActiveRecord::Base
          "AR:#{o.class.name}:#{o.id}"
        when Class, Module
          "CLASS:#{o.name}"
        when Hash
          o.to_yaml
        else
          o
      end
    } if args
  end

  def self.args_from_resque(args)
    args = args.map { |o|
      puts o
      if o
        case o
        when CLASS_STRING_FORMAT  then $1.constantize
        when AR_STRING_FORMAT     then $1.constantize.find_by_id($2)
        when YAML_STRING_FORMAT   then YAML.load(o)
        else o
        end
      end
    } if args
  end

  private
  def self.env_str
    if defined? Rails
      Rails.env.to_s
    elsif defined? Rack
      Rack.env.to_s
    else
      'production'
    end
  end

  @@_config = nil

  def self.config
    return @@_config if @@_config && self.env_str != 'development'

    if File.exists?(DEFAULT_CONFIG_PATH)
      config = YAML.load(ERB.new(IO.read(DEFAULT_CONFIG_PATH)).result)[self.env_str]
    end

    config = {}.merge(DEFAULT_CONFIG || {}).merge(config || {})

    @@_config = config
  end
end
