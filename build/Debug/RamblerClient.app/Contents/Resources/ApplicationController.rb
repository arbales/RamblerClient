# ApplicationController.rb
# RamblerClient
#
# Created by Austin Bales on 10/19/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.


class ApplicationController
		
  attr_accessor :channel_textfield, :message_textfield, :username_textfield, :window, :loginWindow, :sheetController
  	
  def awakeFromNib
		@since = DateTime.now.to_s
    GrowlApplicationBridge.growlDelegate = ""
		
		self.performSelector "checkForLogin", withObject:nil, afterDelay:0.1
	end
	def checkForLogin()
		standardUserDefaults = NSUserDefaults.standardUserDefaults
		if (standardUserDefaults)
			puts standardUserDefaults.objectForKey "Username"
		end
		@sheetController.openSheet(nil)
	end
	
	def doLogin(sender)
		
	end
 
  
  def send_message(sender)
		@message_textfield.setEnabled(false)
		MacRubyHTTP.post("http://localhost/publish", {:payload => {:channel => @channel_textfield.stringValue(),
																	   :text => @message_textfield.stringValue(),
																	   :username => @username_textfield.stringValue()
																	   }}) do
			@message_textfield.setStringValue("").setEnabled(true)
			@window.makeFirstResponder(@message_textfield)																	
    end
  end
  
  def start_check(sender)
		if sender.state == 1
		
			GrowlApplicationBridge.notifyWithTitle(
				"Rambler",
				description: "Rambler is watching for messages on /chat",
				notificationName: "TestMessage",
				iconData: NSData.data,
				priority: 0,
				isSticky: false,
				clickContext: nil
			)
		
			Thread.new do
				start_timer
			end	
		else
			@timer.invalidate()
		end
  end
  
  def start_timer
  	@timer = NSTimer.scheduledTimerWithTimeInterval 5,
							 target: self,
							 selector: 'get_chat:',
							 userInfo: nil,
							 repeats: true

		NSRunLoop.currentRunLoop.runUntilDate(NSDate.distantFuture)
  end
  
  def get_chat(timer)
		finished = false
		_since = @since
		MacRubyHTTP.get("http://desk.austinbales.com/archive/chat?since=#{@since}&before=false&only_current=true") do |lh|
			unless finished
				finished = true
				body = NSString.alloc.initWithData(lh.body, encoding:NSString.defaultCStringEncoding)
				messages = JSON.parse(body)
				messages.each do |m|
					unless m['username'] == @username_textfield.stringValue()
					growl(m)
					end
				end
				@since = DateTime.now.to_s
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
