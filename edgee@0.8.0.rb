class Edgee < Formula
  desc "The full-stack edge platform for your edge-oriented applications."
  homepage "https://github.com/edgee-cloud/edgee"
  url "https://github.com/edgee-cloud/edgee/archive/refs/tags/v0.8.0.tar.gz"
  sha256 "8b38aa5383a274669cda491e0bb96f052d315ef60a5cb17f0a1116438b0ec60b"
  license "Apache-2.0"
  head "https://github.com/edgee-cloud/edgee.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "build", "-p", "edgee", "--bin", "edgee", "--release"
    bin.install "target/release/edgee"
  end
end
