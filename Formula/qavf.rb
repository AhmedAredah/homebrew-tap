class Qavf < Formula
  desc "Configurable data QA/QC for files, dataframes and database queries"
  homepage "https://github.com/AhmedAredah/qavf"
  url "https://files.pythonhosted.org/packages/b9/82/7fa630a5d63e51b79407971457682d954a712151da60845f0c78945872eb/qavf-0.5.0.tar.gz"
  sha256 "29998a815481591200181c58d4ce518a7f5cd38bfe92281f46bccc25cffa349d"
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
