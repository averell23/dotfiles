#!/usr/bin/env ruby
# frozen_string_literal: true

# Minimal Jira Cloud REST API v3 client. It intentionally uses only Ruby's
# standard library so it does not introduce an unmaintained SDK dependency.

require "base64"
require "json"
require "net/http"
require "optparse"
require "uri"

class JiraClient
  REQUIRED_ENVIRONMENT = %w[JIRA_URL JIRA_USERNAME JIRA_API_TOKEN].freeze

  def self.from_environment
    missing = REQUIRED_ENVIRONMENT.select { |name| ENV[name].to_s.empty? }
    unless missing.empty?
      warn "Jira is not connected: missing #{missing.join(', ')}."
      exit 2
    end

    new(ENV.fetch("JIRA_URL"), ENV.fetch("JIRA_USERNAME"), ENV.fetch("JIRA_API_TOKEN"))
  end

  def initialize(base_url, username, api_token)
    @base_uri = URI.parse(base_url.end_with?("/") ? base_url : "#{base_url}/")
    unless @base_uri.is_a?(URI::HTTPS)
      warn "JIRA_URL must be an HTTPS URL."
      exit 2
    end

    @authorization = "Basic #{Base64.strict_encode64("#{username}:#{api_token}")}"
  end

  def get(path, query = {})
    request(Net::HTTP::Get, path, query)
  end

  def put(path, body)
    request(Net::HTTP::Put, path, {}, body)
  end

  def browse_url(key)
    (@base_uri + "browse/#{URI.encode_uri_component(key)}").to_s
  end

  def post(path, body)
    request(Net::HTTP::Post, path, {}, body)
  end

  private

  def request(request_class, path, query, body = nil)
    uri = @base_uri + path.sub(%r{\A/}, "")
    uri.query = URI.encode_www_form(query.compact) unless query.empty?
    request = request_class.new(uri)
    request["Accept"] = "application/json"
    request["Authorization"] = @authorization
    if body
      request["Content-Type"] = "application/json"
      request.body = JSON.generate(body)
    end

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(request) }
    return nil if response.code.to_i == 204

    parsed = JSON.parse(response.body) unless response.body.to_s.empty?
    unless response.is_a?(Net::HTTPSuccess)
      message = parsed.is_a?(Hash) ? (parsed["errorMessages"] || parsed["errors"] || parsed) : response.body
      warn "Jira API request failed (HTTP #{response.code}): #{JSON.generate(message)}"
      exit 1
    end
    parsed
  rescue URI::InvalidURIError => e
    warn "Invalid Jira URL: #{e.message}"
    exit 2
  rescue JSON::ParserError
    warn "Jira API returned non-JSON content (HTTP #{response.code})."
    exit 1
  end
end

DEFAULT_ISSUE_FIELDS = "summary,status,issuetype,priority,assignee,reporter,project,labels,components,fixVersions,created,updated,resolution,description".freeze
DEFAULT_SEARCH_FIELDS = "summary,status,assignee,updated".freeze

# Jira descriptions are Atlassian Document Format (ADF). Convert its textual
# nodes to readable Markdown rather than exposing the underlying JSON.
def adf_to_markdown(node)
  return "" unless node
  return node.map { |child| adf_to_markdown(child) }.join if node.is_a?(Array)
  return node.to_s unless node.is_a?(Hash)

  content = adf_to_markdown(node["content"])
  return "#{node["text"]}#{content}" if node["type"] == "text"
  return "\n#{content}\n" if %w[paragraph heading blockquote listItem].include?(node["type"])
  return "\n" if node["type"] == "hardBreak"

  content
end

def markdown_cell(value)
  text = case value
         when nil then ""
         when Array then value.map { |item| markdown_cell(item) }.reject(&:empty?).join(", ")
         when Hash
           value["displayName"] || value["name"] || value["value"] || value["key"] || value["text"] || JSON.generate(value)
         else value.to_s
         end
  text.gsub(/\R+/, "<br>").gsub("|", "\\|")
end

def present?(value)
  !value.nil? && value != "" && value != [] && value != {}
end

def print_issue_markdown(issue, client)
  fields = issue.fetch("fields", {})
  key = issue.fetch("key")
  summary = markdown_cell(fields["summary"] || key)
  puts "# [#{key}](#{client.browse_url(key)}) — #{summary}"
  puts
  puts "## Details"
  puts "| Field | Value |"
  puts "| --- | --- |"

  detail_fields = {
    "Status" => fields["status"],
    "Type" => fields["issuetype"],
    "Priority" => fields["priority"],
    "Assignee" => fields["assignee"],
    "Reporter" => fields["reporter"],
    "Project" => fields["project"],
    "Labels" => fields["labels"],
    "Components" => fields["components"],
    "Fix versions" => fields["fixVersions"],
    "Resolution" => fields["resolution"],
    "Created" => fields["created"],
    "Updated" => fields["updated"]
  }
  detail_fields.each { |name, value| puts "| #{name} | #{markdown_cell(value)} |" if present?(value) }

  description = adf_to_markdown(fields["description"]).strip
  unless description.empty?
    puts "\n## Description\n\n#{description}"
  end

  known_fields = %w[summary status issuetype priority assignee reporter project labels components fixVersions resolution created updated description]
  additional_fields = fields.reject { |name, value| known_fields.include?(name) || !present?(value) }
  return if additional_fields.empty?

  puts "\n## Additional fields"
  puts "| Field | Value |"
  puts "| --- | --- |"
  additional_fields.each { |name, value| puts "| #{markdown_cell(name)} | #{markdown_cell(value)} |" }
end

def print_search_markdown(result, client, jql)
  issues = result.fetch("issues", [])
  puts "# Jira search results"
  puts
  puts "**JQL:** `#{jql.gsub('`', '\\`')}`"
  is_last = result["isLast"] == true
  puts "\n**isLast:** `#{is_last}`"
  puts "\nReturned **#{issues.length}** ticket#{issues.length == 1 ? "" : "s"}.#{is_last ? " All matching tickets were returned." : " More matching tickets are available."}"
  return if issues.empty?

  puts "\n| Key | Summary | Status | Assignee | Updated |"
  puts "| --- | --- | --- | --- | --- |"
  issues.each do |issue|
    fields = issue.fetch("fields", {})
    key = issue.fetch("key")
    puts "| [#{key}](#{client.browse_url(key)}) | #{markdown_cell(fields["summary"])} | #{markdown_cell(fields["status"])} | #{markdown_cell(fields["assignee"])} | #{markdown_cell(fields["updated"])} |"
  end
end

def parse_json_file(path)
  JSON.parse(File.read(path))
rescue Errno::ENOENT
  warn "Body file not found: #{path}"
  exit 2
rescue JSON::ParserError => e
  warn "Invalid JSON in #{path}: #{e.message}"
  exit 2
end

command = ARGV.shift
case command
when "status"
  missing = JiraClient::REQUIRED_ENVIRONMENT.select { |name| ENV[name].to_s.empty? }
  if missing.empty?
    puts "Jira is connected (credentials are configured)."
  else
    puts "Jira is not connected: missing #{missing.join(', ')}."
    exit 2
  end
when "get"
  key = ARGV.shift
  abort "Usage: jira.rb get ISSUE-123 [--fields summary,status]" unless key
  options = { fields: DEFAULT_ISSUE_FIELDS }
  OptionParser.new { |opts| opts.on("--fields FIELDS", "Comma-separated fields") { |value| options[:fields] = value } }.parse!(ARGV)
  client = JiraClient.from_environment
  print_issue_markdown client.get("/rest/api/3/issue/#{URI.encode_uri_component(key)}", options), client
when "search"
  options = { max_results: 50, fields: DEFAULT_SEARCH_FIELDS }
  parser = OptionParser.new do |opts|
    opts.banner = "Usage: jira.rb search 'project = DEV ORDER BY updated DESC' [options]"
    opts.on("--max-results N", Integer, "Maximum results (default: 50)") { |value| options[:max_results] = value }
    opts.on("--fields FIELDS", "Comma-separated fields") { |value| options[:fields] = value }
  end
  parser.parse!(ARGV)
  jql = ARGV.join(" ")
  abort parser.to_s if jql.empty?
  client = JiraClient.from_environment
  print_search_markdown client.get("/rest/api/3/search/jql", { jql: jql, maxResults: options[:max_results], fields: options[:fields] }), client, jql
when "transitions"
  key = ARGV.shift
  abort "Usage: jira.rb transitions ISSUE-123" unless key
  puts JSON.pretty_generate(JiraClient.from_environment.get("/rest/api/3/issue/#{URI.encode_uri_component(key)}/transitions"))
when "comment"
  key = ARGV.shift
  abort "Usage: jira.rb comment ISSUE-123 --body comment.json --confirm" unless key
  options = { body: nil, confirmed: false }
  parser = OptionParser.new do |opts|
    opts.banner = "Usage: jira.rb comment ISSUE-123 --body comment.json --confirm"
    opts.on("--body FILE", "JSON request body containing an ADF comment") { |value| options[:body] = value }
    opts.on("--confirm", "Required: add the comment") { options[:confirmed] = true }
  end
  parser.parse!(ARGV)
  abort parser.to_s unless options[:body]
  abort "Refusing to add a Jira comment without --confirm." unless options[:confirmed]
  body = parse_json_file(options[:body])
  abort "Comment body must be a JSON object." unless body.is_a?(Hash)
  abort "Comment body must contain a JSON object under 'body'." unless body["body"].is_a?(Hash)
  JiraClient.from_environment.post("/rest/api/3/issue/#{URI.encode_uri_component(key)}/comment", body)
  puts "Commented on #{key}."
when "transition"
  key = ARGV.shift
  abort "Usage: jira.rb transition ISSUE-123 --id TRANSITION_ID --confirm" unless key
  options = { id: nil, confirmed: false }
  parser = OptionParser.new do |opts|
    opts.banner = "Usage: jira.rb transition ISSUE-123 --id TRANSITION_ID --confirm"
    opts.on("--id ID", "Jira transition ID") { |value| options[:id] = value }
    opts.on("--confirm", "Required: perform the ticket transition") { options[:confirmed] = true }
  end
  parser.parse!(ARGV)
  abort parser.to_s unless options[:id]
  abort "Refusing to transition Jira without --confirm." unless options[:confirmed]
  JiraClient.from_environment.post(
    "/rest/api/3/issue/#{URI.encode_uri_component(key)}/transitions",
    { transition: { id: options[:id] } }
  )
  puts "Transitioned #{key}."
when "update"
  key = ARGV.shift
  abort "Usage: jira.rb update ISSUE-123 --body update.json --confirm" unless key
  options = { body: nil, confirmed: false }
  parser = OptionParser.new do |opts|
    opts.banner = "Usage: jira.rb update ISSUE-123 --body update.json --confirm"
    opts.on("--body FILE", "JSON request body for PUT /issue/{key}") { |value| options[:body] = value }
    opts.on("--confirm", "Required: perform the ticket update") { options[:confirmed] = true }
  end
  parser.parse!(ARGV)
  abort parser.to_s unless options[:body]
  abort "Refusing to update Jira without --confirm." unless options[:confirmed]
  body = parse_json_file(options[:body])
  abort "Update body must be a JSON object." unless body.is_a?(Hash)
  JiraClient.from_environment.put("/rest/api/3/issue/#{URI.encode_uri_component(key)}", body)
  puts "Updated #{key}."
else
  warn <<~USAGE
    Usage: jira.rb <command> [options]
      status
      get ISSUE-123 [--fields summary,status]
      search 'JQL query' [--max-results N] [--fields summary,status]
      transitions ISSUE-123
      comment ISSUE-123 --body comment.json --confirm
      transition ISSUE-123 --id TRANSITION_ID --confirm
      update ISSUE-123 --body update.json --confirm
  USAGE
  exit 2
end
