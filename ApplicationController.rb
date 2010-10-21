# ApplicationController.rb
# RamblerClient
#
# Created by Austin Bales on 10/19/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.


class ApplicationController
		
  attr_accessor :channel_textfield, :message_textfield, :username_textfield, :window, :loginWindow, :sheetController, :menuController, :watch_chat, :channels 	
  def awakeFromNib
		@since = {}
    GrowlApplicationBridge.growlDelegate = ""

		@window.makeKeyAndOrderFront(self)
		self.performSelector "checkForLogin", withObject:nil, afterDelay:0.1
		@defaults = NSUserDefaults.standardUserDefaults
	end
	def checkForLogin()
		@sheetController.openSheet(nil)
	end
	
	def applicationDidBecomeActive(notification)
		@window.makeKeyAndOrderFront(self)
	end
	
	def afterLogin()
		#@window.orderOut(nil)
		if (@defaults)
			@channel_textfield.setStringValue "chat"
			#@message_textfield.becomeFirstResponder()
			watching_channels = @defaults.objectForKey("RamblerChannels")
			if ((watching_channels.size > 0) rescue false)
				@channels.setObjectValue(watching_channels)
			else
				@channels.setObjectValue(['chat'])
			end

			is_watching_chat = @defaults.objectForKey("RamblerGrowl")
			if (is_watching_chat == true || is_watching_chat == nil)
				start_check(@watch_chat.setState(1))
			end

			#defaults.setObject @username_field.stringValue(), forKey:"RamblerUsername"
			#defaults.synchronize
		end
	
	end
	
	def updateSubscriptions(sender)
		puts sender.objectValue().inspect()
	end
  
  def send_message(sender)
		@message_textfield.setEnabled(false)
		MacRubyHTTP.post("http://desk.austinbales.com/publish", {:payload => {:channel => @channel_textfield.stringValue(),
																	   :text => @message_textfield.stringValue(),
																	   :username => @defaults.objectForKey("RamblerUsername"),
																		 :client => "desktop"
																	   }}) do
			@message_textfield.setStringValue("").setEnabled(true)
			@window.makeFirstResponder(@message_textfield)																	
    end
  end
  
  def start_check(sender)
		if sender.state == 1
			
			@defaults.setObject true, forKey: "RamblerGrowl"
			@defaults.setObject @channels.objectValue().to_a, forKey: "RamblerChannels"
			
			if (@channels.objectValue().size > 0)
				GrowlApplicationBridge.notifyWithTitle(
					"Rambler",
					description: "Rambler is watching for messages on #{@channels.objectValue.join(', ')}",
					notificationName: "TestMessage",
					iconData: NSData.data,
					priority: 0,
					isSticky: false,
					clickContext: nil
				)
				Thread.new do
					start_timer(@channels.objectValue.to_a)
				end
			end
		else
			@defaults.setObject false, forKey: "RamblerGrowl"

			GrowlApplicationBridge.notifyWithTitle(
				"Goodbye!",
				description: "Rambler will no longer show you Growl alerts.",
				notificationName: "TestMessage",
				iconData: NSData.data,
				priority: 0,
				isSticky: false,
				clickContext: nil
			)
			@timer.invalidate() rescue false
		end
  end
  
  def start_timer(channels)
		channels.each do |chan|
			@since[chan] = DateTime.now.to_s
		end
  	@timer = NSTimer.scheduledTimerWithTimeInterval 5,
							 target: self,
							 selector: 'get_chat:',
							 userInfo: channels,
							 repeats: true

		NSRunLoop.currentRunLoop.runUntilDate(NSDate.distantFuture)
  end
  
  def get_chat(timer)
		queue = Dispatch::Queue.new('com.odopod.rambler.httpreqs')
		channels = timer.userInfo()
		channels.each do |chan|
			queue.sync do
				_since = @since[chan]
				url = "http://desk.austinbales.com/archive/#{chan}?since=#{_since}&before=false&only_current=true"
				puts url
				MacRubyHTTP.get(url) do |lh|
					body = NSString.alloc.initWithData(lh.body, encoding:NSString.defaultCStringEncoding)
					messages = JSON.parse(body)
					messages.each do |m|
							#unless m['username'] == @username_textfield.stringValue()
								growl(m)
							#end
						end
					@since[chan] = DateTime.now.to_s
				end
			end
		end
  end

  def growl(message)
    GrowlApplicationBridge.notifyWithTitle(
      "@#{message['username']} → #{message['channel'].sub('/','')}",
      description: message['text'],
      notificationName: "TestMessage",
      iconData: NSData.data,
      priority: 0,
      isSticky: false,
      clickContext: nil
    )
  end
  
  def do_something(timer)
		puts 'Do something'
	end


end
