#!/usr/bin/env ruby

require 'fileutils'
require 'json'

# Path to Assets.xcassets
assets_path = "/Users/samirsafar/Desktop/SamsGames/SamsGames/SamsGames/Assets.xcassets"

# Create jushbox3D.imageset
jushbox3d_path = File.join(assets_path, "jushbox3D.imageset")
FileUtils.mkdir_p(jushbox3d_path)

contents_json_3d = {
  "images" => [
    {
      "filename" => "jushbox3D.png",
      "idiom" => "universal",
      "scale" => "1x"
    },
    {
      "filename" => "jushbox3D 1.png",
      "idiom" => "universal",
      "scale" => "2x"
    },
    {
      "filename" => "jushbox3D 2.png",
      "idiom" => "universal",
      "scale" => "3x"
    }
  ],
  "info" => {
    "author" => "xcode",
    "version" => 1
  }
}

File.write(File.join(jushbox3d_path, "Contents.json"), JSON.pretty_generate(contents_json_3d))
puts "✅ Created jushbox3D.imageset"

# Create jushbox3dplay.imageset
jushbox3dplay_path = File.join(assets_path, "jushbox3dplay.imageset")
FileUtils.mkdir_p(jushbox3dplay_path)

contents_json_play = {
  "images" => [
    {
      "filename" => "jushbox3dplay.png",
      "idiom" => "universal",
      "scale" => "1x"
    },
    {
      "filename" => "jushbox3dplay 1.png",
      "idiom" => "universal",
      "scale" => "2x"
    },
    {
      "filename" => "jushbox3dplay 2.png",
      "idiom" => "universal",
      "scale" => "3x"
    }
  ],
  "info" => {
    "author" => "xcode",
    "version" => 1
  }
}

File.write(File.join(jushbox3dplay_path, "Contents.json"), JSON.pretty_generate(contents_json_play))
puts "✅ Created jushbox3dplay.imageset"

puts ""
puts "📋 Next steps:"
puts "1. Copy your jushbox3D*.png files to: #{jushbox3d_path}"
puts "2. Copy your jushbox3dplay*.png files to: #{jushbox3dplay_path}"
puts "3. Rebuild the project"
