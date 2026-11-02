class Qavf < Formula
  desc "Configurable data QA/QC for files, dataframes and database queries"
  homepage "https://github.com/AhmedAredah/qavf"
  url "https://files.pythonhosted.org/packages/e8/9b/18e76f596b71ca1ae70e48ce3436e7c0dce5172d8df71cb72419884c11f2/qavf-0.6.2.tar.gz"
  sha256 "c6d2c089cc00234d6b29ff6310b1998ccba5e8b404b62748ac2011401a0e3252"
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
