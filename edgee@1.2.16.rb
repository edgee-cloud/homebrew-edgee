class Edgee < Formula
  desc "The full-stack edge platform for your edge-oriented applications."
  homepage "https://github.com/edgee-cloud/edgee"
  url "https://github.com/edgee-cloud/edgee/archive/refs/tags/v1.2.16.tar.gz"
  sha256 "a51d433e0416cbc39198ac4f0388cf8557120d932fb1cd8c7e1cb3fb150a8e35"
  license "Apache-2.0"
  head "https://github.com/edgee-cloud/edgee.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "build", "-p", "edgee", "--bin", "edgee", "--release"
    bin.install "target/release/edgee"
  end
end
