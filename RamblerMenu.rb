# RamblerMenu.rb
# RamblerClient
#
# Created by Austin Bales on 10/20/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

class RamblerMenu
	attr_accessor :ramMenu
	
	def awakeFromNib()
		status_bar = NSStatusBar.systemStatusBar()
		status_item = status_bar.statusItemWithLength(NSVariableStatusItemLength)
		item_image = NSImage.alloc.initWithContentsOfFile(NSBundle.mainBundle.pathForResource("icon", ofType: "png"))
		status_item.setImage item_image
		status_item.setHighlightMode true
		status_item.setMenu @ramMenu
	end
	
	def quit(sender)
		NSApp.terminate(nil)
	end
	
end