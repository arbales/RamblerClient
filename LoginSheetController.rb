# LoginSheetController.rb
# RamblerClient
#
# Created by Austin Bales on 10/19/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

class LoginSheetController < BWSheetController
	attr_accessor :password_field, :username_field, :wheel, :warning, :delegator
	
	def awakeFromNib()
	
		standardUserDefaults = NSUserDefaults.standardUserDefaults

		if (standardUserDefaults)
				username = standardUserDefaults.objectForKey("RamblerUsername")

			if (username != "")
				password = EMGenericKeychainItem.genericKeychainItemForService("Rambler", withUsername: username)			
			
				if (username && password)
					@username_field.setStringValue(username)
					@password_field.setStringValue(password.password)
					do_login(nil)
				end
			
			end
		
			
		end
	
	end
		
	def do_login(sender)
	
			standardUserDefaults = NSUserDefaults.standardUserDefaults

			if (standardUserDefaults)
				#username = standardUserDefaults.objectForKey("RamblerUsername")
				standardUserDefaults.setObject @username_field.stringValue(), forKey:"RamblerUsername"
				standardUserDefaults.synchronize
			end
	
			@warning.setHidden(true)
			@wheel.startAnimation(nil)
			@password_field.setEnabled false
			@username_field.setEnabled false
			MacRubyHTTP.post("http://desk.austinbales.com/login", {payload: {username: @username_field.stringValue, password: @password_field.stringValue}}) do |response|
				body = NSString.alloc.initWithData(response.body, encoding:NSString.defaultCStringEncoding)
				if (body == "Success")
					puts "Success"
					EMGenericKeychainItem.addGenericKeychainItemForService "Rambler", withUsername:@username_field.stringValue, password:@password_field.stringValue()
					@delegator.closeSheet(nil)
					NSApp.delegate.afterLogin()
				else
					@wheel.stopAnimation(nil)
					@username_field.setEnabled true
					@warning.setStringValue("Incorrect username or password.").setHidden(false)
					@password_field.setStringValue("").setEnabled(true)
				end
			end
		
	end
end

