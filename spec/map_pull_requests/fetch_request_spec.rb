# frozen_string_literal: true

RSpec.describe MapPullRequests::FetchRequest do
  let(:fetch_request) { described_class.new("zsbenke") }
  let(:fixture_path) { File.expand_path("spec/fixtures/fetch_request_results.json") }
  let(:results) { File.read(fixture_path) }

  describe ".github_cli_installed?" do
    subject(:github_cli_installed?) { described_class.github_cli_installed? }

    it "checks for the GitHub command line tool" do
      expect(github_cli_installed?).to be true
    end

    it "raises an error if the GitHub command line tool is not installed" do
      allow(described_class).to receive(:system).and_return(false)
      expect { github_cli_installed? }.to raise_error("GitHub CLI is not installed")
    end
  end

  describe "#data" do
    subject(:data) { fetch_request.data }

    before do
      allow(fetch_request).to receive(:results).and_return(results)
      fetch_request.call
    end

    it "fetches the pull requests from GitHub" do
      expect(data).to be_a(Array)
    end

    it "has the correct number of pull requests" do
      expect(data.size).to eq(2)
    end
  end
end