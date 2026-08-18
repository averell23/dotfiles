---
name: jira
description: Search, retrieve, and update Jira Cloud tickets for betterplace using the Jira REST API v3. Use whenever working with Jira tickets, including looking up DEV issues, running JQL, or proposing or applying ticket changes.
---

# Jira integration

Use the bundled Ruby client:

```bash
.agents/skills/jira/scripts/jira.rb <command>
```

Official API documentation: <https://developer.atlassian.com/cloud/jira/platform/rest/v3>

## Connection and authentication

The client obtains its configuration from environment variables:

- `JIRA_URL` — the full HTTPS Cloud URL, for example `https://betterplace.atlassian.net`
- `JIRA_USERNAME` — the account email used for API-token basic authentication
- `JIRA_API_TOKEN` — the Jira API token

Check the connection before making a Jira request:

```bash
.agents/skills/jira/scripts/jira.rb status
```

If any variable is missing or empty, the command states that Jira is not connected. Never print, log, or put credentials in a command line, ticket body, or response.

## Read tickets

Ticket reads do not need user confirmation.

```bash
# Retrieve a ticket. Request only needed fields when practical. Returns markdown.
.agents/skills/jira/scripts/jira.rb get DEV-12345 --fields summary,status,assignee,description

# Run a JQL search. Returns markdown.
.agents/skills/jira/scripts/jira.rb search 'project = DEV AND status != Done ORDER BY updated DESC' \
  --fields summary,status,assignee
```

The search command calls `GET /rest/api/3/search/jql`; the get command calls `GET /rest/api/3/issue/{issueIdOrKey}`.

## Update tickets and add comments — confirmation is mandatory

**Every Jira mutation is dangerous.** Before updating an issue, adding a comment, or changing its state:

1. Describe the exact intended change (ticket key and fields/new values).
2. Ask the user for explicit permission.
3. Only after permission, make the call with `--confirm`.

The script independently refuses an update, comment, or transition that does not include `--confirm`. This flag is not a substitute for the user's explicit approval in the conversation.

Create a JSON request body without credentials, show it to the user as part of the proposed change, then run:

```bash
cat > /tmp/DEV-12345-update.json <<'JSON'
{
  "fields": {
    "summary": "Clarify donor confirmation email"
  }
}
JSON

.agents/skills/jira/scripts/jira.rb update DEV-12345 \
  --body /tmp/DEV-12345-update.json --confirm
```

`update` calls `PUT /rest/api/3/issue/{issueIdOrKey}`. Its body is passed through to Jira, allowing the REST API's `fields` and `update` formats. Follow the official API field formats: notably, rich-text fields such as `description` use Atlassian Document Format (ADF), not a plain string. Retrieve the issue metadata or use the REST documentation before changing unfamiliar/custom fields.

### Add a comment

Comments use Atlassian Document Format (ADF). Create a request body such as:

```json
{
  "body": {
    "type": "doc",
    "version": 1,
    "content": [
      {
        "type": "paragraph",
        "content": [{ "type": "text", "text": "Comment text" }]
      }
    ]
  }
}
```

After explicit user approval, run:

```bash
.agents/skills/jira/scripts/jira.rb comment DEV-12345 \
  --body /tmp/DEV-12345-comment.json --confirm
```

This calls `POST /rest/api/3/issue/{issueIdOrKey}/comment`. The script requires both the ADF `body` object and `--confirm`.

For transitions, first retrieve the available transitions with `transitions ISSUE-123`. That command prints the raw Jira JSON response so the available transition IDs and names remain machine-readable. Use Jira's issue-transition endpoint only after the same explicit approval; do not guess transition IDs.
