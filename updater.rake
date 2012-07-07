require 'open-uri'
require 'net/https'
require 'fileutils'
require 'yaml'
require 'pathname'

$ASSETS_ROOT = nil
$ASSETS_ROOT = $ROOT if defined? $ROOT
$ASSETS_ROOT = Rails.root if defined? Rails
$ASSETS_ROOT ||= Pathname(Dir.pwd)


namespace :assets do


  desc "Update bootstrap framework from github master"
  task :update do

    assets = YAML::load File.open($ASSETS_ROOT.join("config/assets.yml"))

    assets.each do |vendor,manifest|
      process_assets_manifest vendor,manifest
    end

  end

  def process_assets_manifest(vendor, manifest)
    vendor_root = $ASSETS_ROOT.join("vendor",vendor)

    manifest.each do |category,files|
      if defined? Rails
        download_root = $ASSETS_ROOT.join("vendor/assets",category,vendor)
      else
        download_root = $ASSETS_ROOT.join("vendor",category,vendor)
      end

      FileUtils.mkdir_p download_root
      download_files download_root, files, category
    end

  end

  def download_files(directory,files,category)
    files.map do |name,remote_url|
      local_path = directory.join(name)
      print "Downloading #{remote_url} -> #{relative_path(local_path)} ... "
      open(remote_url) do |content|
        content.binmode
        File.open("#{local_path}.update","w") do |f|
          f.binmode
          f << content.read
        end
        FileUtils.mv "#{local_path}.update", local_path
      end
      puts "done"
    end
  end

  def relative_path(local_path,append="/")
    local_path.to_s.gsub("#{$ASSETS_ROOT.to_s}#{append}", "")
  end

end
