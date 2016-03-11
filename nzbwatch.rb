#!/usr/bin/ruby

require './nzbwatch.conf.rb'
require 'rest-client'
require 'rb-inotify'

raise ("Watch folder '#{WATCH_FOLDER}' does not exist.") unless File.directory? WATCH_FOLDER

notifier = INotify::Notifier.new

notifier.watch(WATCH_FOLDER, :moved_to, :create) do |event|
      filename = event.absolute_name
      filetype = filename.split(".")[-1]
      
      
      if (filetype == "zip" || filetype == "gz")
         filetype = filename.split(".")[-2]
         if (filetype == "tar")
            filetype = filename.split(".")[-3]
         end
      end
      
      if filetype == "nzb"
         begin
            RestClient.post('http://nemo:8080/sabnzbd/api', 
               nzbfile: File.new(filename),
               apikey:  "3954fc9ccf03c717c39c67aaef4250bd",
               mode:    "addfile"
            )
            
            if (DELETE_NZB_AFTER_UPLOAD)
               File.delete(filename)
            end

         rescue => exception
            puts "some error happened", exception.message
         end
      end
end

notifier.run
