cask "attention-awareness" do
  version "0.5.1,11"
  sha256 "22e97e0fec42ef9eb37487a9128944876aa7e4f00551688111c41bbe27859cc9"

  url "https://attentionawareness.com/mac/attention-awareness-#{version.csv.first}-#{version.csv.second}.dmg"
  name "attention awareness"
  desc "Supervises an iPhone to block apps and websites permanently"
  homepage "https://attentionawareness.com/"

  livecheck do
    url "https://attentionawareness.com/mac/appcast.xml"
    strategy :sparkle
  end

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
