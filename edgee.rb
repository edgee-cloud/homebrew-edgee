class Edgee < Formula
  desc "The full-stack edge platform for your edge-oriented applications."
  homepage "https://github.com/edgee-cloud/edgee"
  url "https://github.com/edgee-cloud/edgee/archive/refs/tags/v1.2.19.tar.gz"
  sha256 "598b55eeda37fed8a870914f07a90124085c8dbcd1c6d8be5ed36dc20a8c2c8e"
  license "Apache-2.0"
  head "https://github.com/edgee-cloud/edgee.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "build", "-p", "edgee", "--bin", "edgee", "--release"
    bin.install "target/release/edgee"
  end
end
