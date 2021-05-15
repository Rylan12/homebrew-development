class RelocationTesting < Formula
  desc "Formula for testing bottle relocation"
  homepage "https://www.example.org"
  url "file://#{HOMEBREW_LIBRARY}/Taps/rylan12/homebrew-development/src/relocation-testing.tar.gz"
  version "1.0.0"
  sha256 "7bcbfbcfad89fa1968668e5b3801495578f10456c01dc3fdcac3a641a5ce800a"
  license "GPL-3.0-or-later"

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
