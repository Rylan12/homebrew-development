class DevBottle < Formula
  desc "Aescrypt: Program for encryption/decryption"
  homepage "https://aescrypt.sourceforge.io/"
  url "https://aescrypt.sourceforge.io/aescrypt-0.7.tar.gz"
  sha256 "7b17656cbbd76700d313a1c36824a197dfb776cadcbf3a748da5ee3d0791b92d"

  bottle do
    root_url "https://github.com/Rylan12/homebrew-development/releases/download/dev-bottle-0.7"
    cellar :any_skip_relocation
    sha256 "335745fc4b34927db2ee03432a107647194f3086473f7c394485183171217e01" => :catalina
    sha256 "8a4d25005211e8e0da93a05917f2f7f7f731e33aa2ae0889e13cf9b30771f8df" => :x86_64_linux
  end

  conflicts_with "aescrypt", because: "both install `aescrypt` and `aesget` binaries"

  def install
    system "./configure"
    system "make"
    bin.install "aescrypt", "aesget"
  end

  test do
    (testpath/"key").write "kk=12345678901234567890123456789abc0"
    original_text = "hello"
    cipher_text = pipe_output("#{bin}/aescrypt -k #{testpath}/key -s 128", original_text)
    deciphered_text = pipe_output("#{bin}/aesget -k #{testpath}/key -s 128", cipher_text)
    assert_not_equal original_text, cipher_text
    assert_equal original_text, deciphered_text
  end
end
