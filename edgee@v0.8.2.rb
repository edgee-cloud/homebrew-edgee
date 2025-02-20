class Edgee < Formula
  desc "The full-stack edge platform for your edge-oriented applications."
  homepage "https://github.com/edgee-cloud/edgee"
  url "https://github.com/edgee-cloud/edgee/archive/refs/tags/v0.8.2.tar.gz"
  sha256 "d841a127154309bcf2cf976c626980824e646eab3fc0c8b922447294d1ad8265"
  license "Apache-2.0"
  head "https://github.com/edgee-cloud/edgee.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "build", "-p", "edgee", "--bin", "edgee", "--release"
    bin.install "target/release/edgee"
  end
end
