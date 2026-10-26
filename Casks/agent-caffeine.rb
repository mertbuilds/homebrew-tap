cask "agent-caffeine" do
  version "1.2.3,33"
  sha256 "efc6066882f1227c0537e2cd2a14ee66e14f9b4d3f235f0cd55835712efc17e6"

  url "https://caffeinagent.com/mac/agent-caffeine-#{version.csv.first}-#{version.csv.second}.dmg"
  name "Agent Caffeine"
  desc "Menu bar tool that prevents sleep while AI coding agents work"
  homepage "https://caffeinagent.com/"

  livecheck do
    url "https://caffeinagent.com/mac/appcast.xml"
    strategy :sparkle
  end

  auto_updates true
  depends_on macos: :ventura

  app "Agent Caffeine.app"
  binary "#{appdir}/Agent Caffeine.app/Contents/MacOS/agent-caffeine"

  uninstall launchctl: "com.caffeinagent.app.helper",
            quit:      "com.caffeinagent.app"

  zap delete: [
        "/etc/sudoers.d/caffeinagent",
        "/Library/Application Support/com.caffeinagent.app",
      ],
      trash:  [
        "~/Library/Application Support/com.caffeinagent.app",
        "~/Library/Caches/com.caffeinagent.app",
        "~/Library/HTTPStorages/com.caffeinagent.app",
        "~/Library/Preferences/com.caffeinagent.app.plist",
      ]

  caveats <<~EOS
    Agent Caffeine is paid software with a 7 day trial.

    Uninstalling does not change the hooks and skills that "Set up for agents"
    wrote into the folders of your agents (for example ~/.claude). Remove them
    in Agent Caffeine > Settings before you uninstall. The license stays in
    the login keychain.
  EOS
end
