# frozen_string_literal: true

require "uri"

module Tsclient
  class ApiFinder
    def call(env: ENV, ruby_platform: RUBY_PLATFORM)
      os = find_os(ruby_platform)
      if env.key?("TSCLIENT_API_URI")
        URI(env.fetch("TSCLIENT_API_URI"))
      elsif os == "linux"
        # Running on Linux, default socket path
        URI("unix:///var/run/tailscale/tailscaled.sock")
      elsif os == "macos"
        # Running on macOS, api port & auth are in a specific filename
        if (tsfile = Pathname.glob("#{env["HOME"]}/Library/Group Containers/*.io.tailscale.ipn.macos/sameuserproof-*-*").first)
          _, port, password = tsfile.basename.to_s.split("-", 3)
          URI("http://:#{password}@localhost:#{port}")
        end
      end
    end

    private

    def find_os(ruby_platform)
      case ruby_platform
      when /cygwin|mswin|mingw|bccwin|wince|emx/
        "windows"
      when /darwin/
        "macos"
      else
        "linux"
      end
    end
  end
end
