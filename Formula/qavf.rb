class Qavf < Formula
  desc "Configurable data QA/QC for files, dataframes and database queries"
  homepage "https://github.com/AhmedAredah/qavf"
  url "https://files.pythonhosted.org/packages/35/b6/abf09069560b1c8a0d67346a6bc6bbbb7a005473e41f82d28710d286974c/qavf-0.6.0.tar.gz"
  sha256 "580a387c09f057b529a8739d7a5013306f7cd78e1389367e43c94083fbba122a"
  license "MIT"

  livecheck do
    url :stable
    strategy :pypi
  end

  depends_on "python@3.12"

  def install
    python = Formula["python@3.12"].opt_bin/"python3.12"
    system python, "-m", "venv", libexec
    # Dependencies such as DuckDB, Polars and PyArrow install as their official
    # wheels; building them from source is impractical outside homebrew-core.
    system libexec/"bin/pip", "install", "--no-cache-dir", "#{buildpath}[stats]"
    bin.install_symlink libexec/"bin/qavf"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/qavf --version")
    system bin/"qavf", "demo", testpath/"demo", "--clean"
    system bin/"qavf", "run", "-c", testpath/"demo/qavf.yaml"
  end
end
