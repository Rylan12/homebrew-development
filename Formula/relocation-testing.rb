class RelocationTesting < Formula
  desc "Formula for testing bottle relocation"
  homepage "https://www.example.org"
  url "file://#{HOMEBREW_LIBRARY}/Taps/rylan12/homebrew-development/src/relocation-testing.tar.gz"
  version "1.0.0"
  sha256 "7bcbfbcfad89fa1968668e5b3801495578f10456c01dc3fdcac3a641a5ce800a"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/Rylan12/homebrew-development/releases/download/relocation-testing-1.0.0"
    sha256                               catalina:     "407ebb3fea7b877275643de764d7c06ae2728389f4a73745e4418ee148da7c3d"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "312ce58397c291a7309a3534dbd07cee4fe539d43f0781d85087c4f7d7adc1d8"
  end

  depends_on "llvm"

  def install
    llvm = Formula["llvm"]
    ldflags = %W[
      -L#{llvm.opt_lib}
      -lLLVM
      -Wl,-rpath,#{llvm.opt_lib}
      -Wl,-rpath,@loader_path/
    ]
    system ENV.cc, "-o", shared_library("libbar"), "-shared", *ldflags, "bar.c"
    ldflags += %w[-lbar -L.]
    system ENV.cc, "-o", shared_library("libfoo"), "-shared", *ldflags, "foo.c"
    lib.install shared_library("libfoo")
    lib.install shared_library("libbar")
  end

  test do
    (testpath/"test.c").write <<~EOS
      int foo(void);
      int main() {
        if (foo() == 0) return 0;
        return 1;
      }
    EOS
    system ENV.cc, "-L#{lib}", "-lfoo", "test.c", "-o", "test"
    system "./test"
  end
end
