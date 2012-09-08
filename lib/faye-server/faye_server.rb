module FayeServer
	attr_accessor :messaging_server_thread, :messaging_server, :messaging_server_port, :messaging_server_options
  attr_accessor :use_ssl, :ssl_key, :ssl_cert
	# Starts the Faye Server in a new thread
	def start
		raise 'Already Running' if self.messaging_server and self.messaging_server_thread.status
		self.messaging_server_thread = Thread.new do
			self.messaging_server = Faye::RackAdapter.new(self.messaging_server_options)
			if self.use_ssl
			  raise 'NoSSLKey' unless self.ssl_key
			  raise 'NoSSLCert' unless self.ssl_cert
			  self.messaging_server.listen(self.messaging_server_port, key: self.ssl_key, cert: self.ssl_cert)
			else
			  self.messaging_server.listen(self.messaging_server_port)
			end
		end
	end

	# Stops Faye Server
	# Somtimes Thin will return that it is wating on a client connection and you need to hit "ctrl-c"
	def stop
		raise 'Not Running' if !self.messaging_server or !self.messaging_server_thread.status
		self.messaging_server.stop
		self.messaging_server_thread.kill
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