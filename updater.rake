require 'open-uri'
require 'net/https'
require 'fileutils'
require 'yaml'
# def update_assets(group,assets)
#   
# end
namespace :assets do


  desc "Update bootstrap framework from github master"
  task :update do  

    assets = YAML::load File.open($ROOT.join("config/assets.yml"))

    assets.each do |vendor,manifest|
      process_assets_manifest vendor,manifest
    end

  end
  
  def process_assets_manifest vendor, manifest
    vendor_root = $ROOT.join("vendor",vendor)

    manifest.each do |category,files|
      download_root = $ROOT.join("vendor",category,vendor)
      FileUtils.mkdir_p download_root
      download_files download_root, files, category
    end

  end

  def download_files(directory,files,category)
    files.map do |name,remote_url|
      local_path = directory.join(name)
      print "Downloading #{remote_url} -> #{relative_path(local_path)} ... "
      open(remote_url) do |content|
        File.open("#{local_path}.update","w") { |f| f << content.read }
        FileUtils.mv "#{local_path}.update", local_path
      end
      puts "done"
    end
  end
  
  def relative_path(local_path,append="/")
    local_path.to_s.gsub("#{$ROOT.to_s}#{append}", "")
  end

end
