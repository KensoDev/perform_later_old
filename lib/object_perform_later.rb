module ObjectPerformLater
  def perform_later!(queue, method, *args)
    if Web::CONFIG['perform_later']
    	Resque::Job.create(queue, ObjectWorker, self.name, method, *args)
		else
			self.send(method, *args)
		end
  end
end

Object.send :include, ObjectPerformLater