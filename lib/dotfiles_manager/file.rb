
class DotfilesManager::File

  attr_accessor :entry
  attr_accessor :path, :storage

  def initialize(manager)
    @manager = manager
  end

  def _get_storage_path()
    storage = @storage || @manager.config.get(:default_storage)
    target = File.join(DotfilesManager::PATH, storage)
    path = @path

    if path.start_with?('/')
      target = File.join(target, '.root')
    elsif path.start_with?('~/')
      path = path[2..-1]
    else
      raise "File path must start with \"/\" or \"~/\" for entry #{entry}"
    end

    target = File.join(target, path)
  end

  def pull(options)
    source = _get_storage_path()
    target = File.expand_path(@path)
    _replace_file(source, target)
  end

  def push(options)
    target = _get_storage_path()
    @manager.run('mkdir', '-p', File.dirname(target))
    _replace_file(source, target)
  end

  def _replace_file(source, target)
    @manager.run('mkdir', '-p', File.dirname(target))

    sudo = []
    if target.start_with?('/')
      sudo.push('sudo')
    end

    if File.exist?(source) && File.exist?(target)
      @manager.run(*sudo, 'rm', '-rf', target)
    end

    @manager.run(*sudo, 'cp', '-R', source, target)
  end

end