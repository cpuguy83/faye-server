module FayeServer
	attr_accessor :messaging_server_thread, :messaging_server, :messaging_server_port, :messaging_server_options

	def start(options={})
		raise 'Already Running' if self.messaging_server and self.messaging_server_thread.status
		self.messaging_server_thread = Thread.new do
			self.messaging_server = Faye::RackAdapter.new(self.messaging_server_options)
			self.messaging_server.listen(self.messaging_server_port)
		end
	end

	def stop
		raise 'Not Running' if !self.messaging_server or !self.messaging_server_thread.status
		self.messaging_server.stop
		if self.messaging_server_thread == 'dead'
			true
		else
			false
		end
	end

	def publish(options={})
		raise 'No Channel Provided' if !options[:channel]
		raise 'No Message Provided' if !options[:message]
		self.messaging_server.get_client.publish(options[:channel], options[:message])
	end
end