require 'pathname'
require 'sprockets'
require 'yui/compressor'

namespace :assets do
  
  def write_asset(target,asset)
    path_for(asset).tap do |path|
      filename = target.join(path)
      FileUtils.mkdir_p File.dirname(filename)
      puts "Generating #{asset.logical_path} -> #{filename}"
      asset.write_to(filename)
      asset.write_to("#{filename}.gz") if filename.to_s =~ /\.(css|js)$/      
    end
  end
  
  def path_for(asset)
    asset.logical_path =~ /\.html$/ ? asset.logical_path : asset.digest_path
  end
  
  def compile_path?(logical_path)
    /(?:\/|\\|\A)application\.(css|js)$/ =~ logical_path ||
    logical_path =~ /\.html$/
  end
  
  desc "Compile all the assets named in config.assets.precompile"
  task :compile do
    
    require $ROOT.join("lib/rack_application")
    app     = RackApplication.new($ROOT)
    env     = app.assets
    
    env.js_compressor = YUI::JavaScriptCompressor.new :munge => true, :optimize => true
    # env.css_compressor = YUI::CssCompressor.new

    
    target  = app.public_path

    system "rm -rf #{target}/*"
    
    manifest = {}
    env.each_logical_path do |logical_path|
      next unless compile_path?(logical_path)
      if asset = env.find_asset(logical_path)
        manifest[logical_path] = write_asset(target,asset)
      end
    end
    
    File.open("#{target}/manifest.yml", 'wb') do |f|
      YAML.dump(manifest, f)
    end
    
    
  end
end
