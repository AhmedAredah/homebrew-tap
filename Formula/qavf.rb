class Qavf < Formula
  desc "Configurable data QA/QC for files, dataframes and database queries"
  homepage "https://github.com/AhmedAredah/qavf"
  url "https://files.pythonhosted.org/packages/c7/b8/5794b459031eef547616bbd5077d70e2242616053c23c7443e734cec532f/qavf-0.4.0.tar.gz"
  sha256 "83c01180605182e363d4548a4d250f78201ea5a80f166f23aeea13761bc8f88f"
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
