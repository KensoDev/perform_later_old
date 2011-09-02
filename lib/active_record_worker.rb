class ActiveRecordWorker
  def self.perform(klass, id, method, *args)
    klass.capitalize.constantize.find(id).send(method, *args)
  end
end