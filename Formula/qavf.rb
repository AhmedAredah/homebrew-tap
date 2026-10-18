class Qavf < Formula
  desc "Configurable data QA/QC for files, dataframes and database queries"
  homepage "https://github.com/AhmedAredah/qavf"
  url "https://files.pythonhosted.org/packages/1f/70/5c14ad437bbe31f54da459a57098bf5e0184697200d1c2372e12802895c6/qavf-0.4.1.tar.gz"
  sha256 "c1081894d38e478d8b0166d7e3b814264f94c86585614f849241636102e38310"
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
