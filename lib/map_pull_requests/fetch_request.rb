# frozen_string_literal: true

require "json"

module MapPullRequests
  # Gets the pull requests from GitHub.
  class FetchRequest
    attr_reader :user, :results, :data

    def initialize(user)
      @user = user
      @results = nil
      @data = nil
    end

    def call
      raise "GitHub CLI is not installed" unless self.class.github_cli_installed?

      fetch_results
      build_data
    end

    def self.github_cli_installed?
      system("gh --version > /dev/null").tap do |installed|
        return installed
      end
    end

    private

    def fetch_results
      @results = `#{command}`
    end

    def build_data
      @data = JSON.parse(results)
      @data = @data["data"]["user"]["pullRequests"]["edges"].map { |edge| edge["node"] }
    end

    def command
      "gh api graphql -f query='#{query}' -F login='#{user}'"
    end

    def query
      <<-GRAPHQL
        query($login: String!) {
          user(login: $login) {
            pullRequests(first: 100, states: [OPEN], orderBy: {field: UPDATED_AT, direction: DESC}) {
              edges {
                node {
                  title
                  number
                  state
                  url
                  createdAt
                  closedAt
                }
              }
            }
          }
        }
      GRAPHQL
    end
  end
end
