cask "attention-awareness" do
  version "0.5.1,11"
  sha256 "22e97e0fec42ef9eb37487a9128944876aa7e4f00551688111c41bbe27859cc9"

  # The site retired the Mac app and sends other visitors to Wax; it still
  # serves the versioned dmgs to Sparkle, so the download says it is Sparkle.
  url "https://attentionawareness.com/mac/attention-awareness-#{version.csv.first}-#{version.csv.second}.dmg",
      user_agent: "attention awareness/#{version.csv.second} Sparkle/2"
  name "attention awareness"
  desc "Supervises an iPhone to block apps and websites permanently"
  homepage "https://attentionawareness.com/"

  livecheck do
    url "https://attentionawareness.com/mac/appcast.xml"
    strategy :sparkle
  end

  deprecate! date: "2026-10-27", because: :discontinued

  auto_updates true
  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "attention awareness.app"

  uninstall quit: "com.attentionawareness.mac"

  zap trash: [
    "~/Library/Application Support/attention awareness",
    "~/Library/Caches/com.attentionawareness.mac",
    "~/Library/HTTPStorages/com.attentionawareness.mac",
    "~/Library/Preferences/com.attentionawareness.mac.plist",
  ]
end
