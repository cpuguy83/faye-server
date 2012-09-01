module Publisher
	attr_accessor :messaging_server_thread, :messaging_server, :messaging_server_port, :messaging_server_options

	def included(base)
		self.base.extend(ClassMethods)
	end

	module ClassMethods

		def start_messaging_server(options={})
			raise 'Already Running' if self.messaging_server.status
			self.messaging_server_thread = Thread.new do
				self.messaging_server = Faye::RackAdapter.new(self.messaging_server_options)
				self.messaging_server.listen(self.messaging_server_port)
			end
		end

		def stop_messaging_server
			raise 'Not Running' if !self.messaging_server.status
			self.messaging_server.stop
		end

		def publish(options={})
			raise 'No Channel Provided' if !options[:channel]
			raise 'No Message Provided' if !options[:message]
			self.messaging_server.get_client.publish(options)
		end
	end

end