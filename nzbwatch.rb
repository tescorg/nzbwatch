#!/usr/bin/ruby

require "rest-client"
require "rb-inotify"
require "yaml"

# Ensure an instance is not already running
unless File.open($PROGRAM_NAME, "r").flock(File::LOCK_EX | File::LOCK_NB)
  raise "Already running"
end

# Assert user's home directory
if ENV["HOME"].nil? || ENV["HOME"].empty?
  require "etc"
  ENV["HOME"] = Etc.getpwuid.dir
end
home_dir = ENV["HOME"]

raise "Could not assert home directory" if home_dir.nil? || home_dir.empty?

# Read config file, if doesn't exist, create one
config_dir = File.absolute_path(".config/nzbwatch", home_dir)
config_filepath = File.absolute_path("nzbwatch.yml", config_dir)

unless File.file? config_filepath
  unless File.file? "/etc/nzbwatch-sample.yml"
    raise "Could not read default config /etc/nzbwatch-sample.yml"
  end

  require "fileutils"
  FileUtils.mkdir_p config_dir
  FileUtils.copy "/etc/nzbwatch-sample.yml", config_filepath
  FileUtils.chmod_R "u=wrx", config_dir
end

config = YAML.load_file config_filepath

if config["WatchFolder"].nil? || config["WatchFolder"].empty?
  raise "Watch folder not configured"
end

unless config["WatchFolder"].is_a? String
  raise "WatchFolder must be a folder path"
end

config["WatchFolder"] = File.expand_path config["WatchFolder"]

unless File.directory? config["WatchFolder"]
  raise "Watch folder #{config["WatchFolder"]} does not exist"
end

if config["ApiKey"].nil? || config["ApiKey"].empty?
  raise "API Key not configured"
end

if config["SABAddress"].nil? || config["SABAddress"].empty?
  raise "SABnzbd api address not configured"
end

config["DeleteNZBPostUpload"] = false if config["DeleteNZBPostUpload"].nil?

config["ArchiveFolder"] = false if config["ArchiveFolder"].nil?

if config["DeleteNZBPostUpload"] && config["ArchiveFolder"]
  raise "DeleteNZBPostUpload and ArchiveFolder cannot be enabled simultaneously"
end

if config["ArchiveFolder"]
  require "fileutils"

  unless config["ArchiveFolder"].is_a? String
    raise "ArchiveFolder must be a folder path"
  end

  config["ArchiveFolder"] = File.expand_path config["ArchiveFolder"]

  unless File.directory? config["ArchiveFolder"]
    raise "Archive folder #{config["ArchiveFolder"]} does not exist"
  end

  unless File.writable? config["ArchiveFolder"]
    raise "No write permission for archive folder #{config["ArchiveFolder"]}"
  end
end

# Now start the INotify loop

puts "Monitoring for NZBs in #{config["WatchFolder"]} ..."

notifier = INotify::Notifier.new

notifier.watch(config["WatchFolder"], :moved_to, :create) do |event|
  filename = event.absolute_name
  basename = File.basename(filename)
  filetype = basename.split(".")[-1]
  filetype = basename.split(".")[-2] if filetype == "zip" || filetype == "gz"
  filetype = basename.split(".")[-3] if filetype == "tar"

  if filetype == "nzb"
    print "Found nzb #{filename} ... "
    begin

      RestClient.post(
        config["SABAddress"],
        nzbfile: File.new(filename),
        apikey: config["ApiKey"],
        mode: "addfile"
      )

      puts "Upload successful"

      File.delete(filename) if config["DeleteNZBPostUpload"]

      if config["ArchiveFolder"]
        FileUtils.mv(
          filename,
          File.absolute_path(basename, config["ArchiveFolder"])
        )
      end

    rescue => exception
      puts "Upload failed", exception.message
    end
  end
end

notifier.run
