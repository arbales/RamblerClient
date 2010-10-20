# LoginSheetController.rb
# RamblerClient
#
# Created by Austin Bales on 10/19/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

class LoginSheetController < BWSheetController
	attr_accessor :password_field, :username_field, :wheel, :warning
		
	def do_login(sender)
			@warning.setHidden(true)
			@wheel.startAnimation(nil)
			@password_field.setEnabled false
			@username_field.setEnabled false
			
			MacRubyHTTP.post("http://desk.austinbales.com/login", {payload: {username: @username_field.stringValue, password: @password_field.stringValue}}) do |response|
				body = NSString.alloc.initWithData(response.body, encoding:NSString.defaultCStringEncoding)
				if (body == "Success")
					self.closeSheet(nil)
					return true
				else
					@wheel.stopAnimation(nil)
					@username_field.setEnabled true
					@warning.setStringValue("Incorrect username or password.").setHidden(false)
					@password_field.setStringValue("").setEnabled(true)
				end
			end
		
	end
	
	def closeSheet(sender)
		puts "closeSheet"
	end
end

