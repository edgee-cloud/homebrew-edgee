class Edgee < Formula
  desc "The full-stack edge platform for your edge-oriented applications."
  homepage "https://github.com/edgee-cloud/edgee"
  url "https://github.com/edgee-cloud/edgee/archive/refs/tags/v1.2.1.tar.gz"
  sha256 "a55bb95ae3d3a5cbe2558a60d3f5a3ca940056138236ea6d50696a897ab01d41"
  license "Apache-2.0"
  head "https://github.com/edgee-cloud/edgee.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "build", "-p", "edgee", "--bin", "edgee", "--release"
    bin.install "target/release/edgee"
  end
end
