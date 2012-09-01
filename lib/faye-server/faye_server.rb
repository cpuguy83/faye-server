module FayeServer
	attr_accessor :messaging_server_thread, :messaging_server, :messaging_server_port, :messaging_server_options

	# Starts the Faye Server in a new thread
	def start(options={})
		raise 'Already Running' if self.messaging_server and self.messaging_server_thread.status
		self.messaging_server_thread = Thread.new do
			self.messaging_server = Faye::RackAdapter.new(self.messaging_server_options)
			self.messaging_server.listen(self.messaging_server_port)
		end
	end

	# Stops Faye Server
	# Somtimes Thin will return that it is wating on a client connection and you need to hit "ctrl-c"
	def stop
		raise 'Not Running' if !self.messaging_server or !self.messaging_server_thread.status
		self.messaging_server.stop
		if self.messaging_server_thread == 'dead'
			true
		else
			false
		end
	end

	# Publish a message to a given channel
	# Requres a :channel, and a :message
	def publish(options={})
		raise 'No Channel Provided' if !options[:channel]
		raise 'No Message Provided' if !options[:message]
		self.messaging_server.get_client.publish(options[:channel], options[:message])
	end
end