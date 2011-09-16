class ActiveRecordWorker
  def self.perform(klass, id, method, *args)
    args = ResquePerformLater.args_from_resque(args)
    runner_klass = eval(klass)
    record = runner_klass.find_by_id(id)
    record.send(method, *args) if record
  end
end