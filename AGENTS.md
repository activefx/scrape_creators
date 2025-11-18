# Scrape Creators Project - AI Agent Guidelines

> **⚠️ IMPORTANT: This is the primary agent configuration file.**
> 
> - **DO NOT edit** `.cursorrules` or `CLAUDE.md` - they are symlinks to this file
> - **ONLY edit** `AGENTS.md` when adding or modifying agent rules
> - Changes to `AGENTS.md` automatically apply to all agent specifications
> - The symlinks ensure compatibility across different AI assistants (Cursor, Claude, etc.)

## Project Overview

The `scrape_creators` gem is a Ruby client library for the ScrapeCreators API, which provides social media data extraction capabilities. This gem provides a clean, idiomatic Ruby interface for interacting with the ScrapeCreators REST API.

### Key Features
- Faraday-based HTTP client with middleware support
- Automatic retry logic and error handling
- HTTP caching support
- Cookie and redirect handling
- Comprehensive test coverage with VCR cassettes
- Zeitwerk-based autoloading

### Core Technologies
- **HTTP Client**: Faraday 2.12+ with middleware stack
- **Testing**: Minitest with VCR for HTTP interaction recording
- **Autoloading**: Zeitwerk for clean code organization
- **Documentation**: YARD for API documentation

### Project Structure
```
lib/
  scrape_creators.rb          # Main entry point
  scrape_creators/
    version.rb                # Version constant
    client.rb                 # HTTP client wrapper
    configuration.rb          # Configuration management
    resources/                # API resource classes
    errors.rb                 # Custom error classes
test/
  test_helper.rb             # Test configuration
  support/                   # Test support files
    vcr.rb                   # VCR configuration
  vcr_cassettes/             # Recorded HTTP interactions
```

## Code Style & Testing

### Testing Framework: Minitest
- Use Minitest spec style with `describe` blocks for test organization
- **Never use comment-based test grouping** - use proper `describe` blocks instead
- Use `let` for test fixtures and shared data
- Use `it` blocks for individual test cases
- Prefer predicate assertions: `assert_predicate obj, :method?` over `assert obj.method?`
- Follow Minitest best practices from: https://docs.seattlerb.org/minitest/

### Test Organization Pattern
```ruby
describe MyClass do
  let(:fixture) { "value" }
  
  describe "feature group" do
    it "does something specific" do
      # test code
    end
  end
end
```

### Ruby Style
- Follow existing `.rubocop.yml` configuration
- Use frozen string literals
- Prefer delegation over manual method definitions
- Use ActiveSupport extensions where appropriate

## Architecture Patterns

### Client Architecture
The gem follows a resource-based architecture pattern common in REST API clients:

1. **Client Class**: Central class managing configuration and HTTP connection
   - Holds API credentials and base URL
   - Configures Faraday connection with middleware
   - Provides access to resource classes

2. **Resource Classes**: Each API resource (e.g., Creators, Posts) is a separate class
   - Inherit from a base Resource class
   - Provide CRUD methods mapped to API endpoints
   - Return domain objects, not raw JSON

3. **Domain Objects**: Plain Ruby objects representing API entities
   - Immutable value objects when possible
   - Use `attr_reader` for read-only attributes
   - Include helper methods for common operations

### Configuration Pattern
Support both global configuration and per-instance configuration:

```ruby
# Global configuration
ScrapeCreators.configure do |config|
  config.api_key = "your_api_key"
  config.base_url = "https://api.scrapecreators.com"
  config.timeout = 30
end

# Per-instance configuration
client = ScrapeCreators::Client.new(
  api_key: "your_api_key",
  timeout: 60
)
```

### Error Handling Strategy
- Define custom error hierarchy under `ScrapeCreators::Error`
- Map HTTP status codes to specific error classes
- Preserve original error context for debugging
- Provide helpful error messages

### Middleware Stack
Faraday middleware should be ordered carefully:
1. Request logging (if enabled)
2. Authentication
3. Encoding handling
4. Retry logic
5. HTTP caching
6. Cookie management
7. Redirect following
8. GZIP compression
9. Response parsing

### Authentication Pattern
API authentication should be handled via Faraday middleware:

```ruby
module ScrapeCreators
  module Middleware
    class Authentication < Faraday::Middleware
      def initialize(app, api_key)
        super(app)
        @api_key = api_key
      end

      def call(env)
        env[:request_headers]["Authorization"] = "Bearer #{@api_key}"
        @app.call(env)
      end
    end
  end
end
```

### Rate Limiting Pattern
Implement rate limit handling with retry logic:

```ruby
module ScrapeCreators
  module Middleware
    class RateLimit < Faraday::Middleware
      def call(env)
        response = @app.call(env)

        if response.status == 429
          retry_after = response.headers["Retry-After"]&.to_i || 60
          raise RateLimitError.new(
            "Rate limit exceeded. Retry after #{retry_after} seconds",
            retry_after: retry_after
          )
        end

        response
      end
    end
  end
end
```

Configure retry logic to handle transient failures:
```ruby
connection.request :retry,
  max: 3,
  interval: 0.5,
  backoff_factor: 2,
  retry_statuses: [429, 500, 502, 503, 504],
  methods: [:get, :post, :put, :delete]
```

### Resource Pattern
```ruby
module ScrapeCreators
  class Resource
    attr_reader :client

    def initialize(client)
      @client = client
    end

    private

    def get(path, params = {})
      client.connection.get(path, params)
    end

    def post(path, body = {})
      client.connection.post(path, body)
    end
  end
end
```

## Documentation

### YARD Documentation (Configured)
- Project uses YARD for API documentation generation
- All public methods must have YARD documentation
- Include `@param`, `@return`, `@option` tags with types
- Add `@example` blocks for complex methods
- Document error conditions and edge cases
- Generate docs with: `rake yard`
- View docs: open `doc/index.html`

### YARD Documentation Style
```ruby
# Brief description of what the method does
#
# @param name [Type] Description of parameter
# @param options [Hash] Options hash
# @option options [Type] :key Description of option
# @return [Type] Description of return value
# @raise [ErrorClass] When this error occurs
#
# @example Basic usage
#   obj.method(arg)
#   # => result
def method(name, options = {})
  # implementation
end
```

### Usage Documentation
- Create comprehensive usage guides in `docs/` directory
- Include quick start, API reference, examples, and common patterns
- Use real-world examples
- **Do not create refactoring summaries or implementation notes**

## Files to Modify with Permission Only
- `lib/scrape_creators.rb` - Core module definition
- Any files not explicitly mentioned in the task
- Git configuration
- Gemspec or Gemfile (unless specifically requested)

## Testing Requirements

### General Testing Guidelines
- All new features must have comprehensive tests
- Test both success and failure paths
- Test edge cases (nil, empty, malformed input)
- Create VCR cassettes for HTTP interactions
- Ensure all tests pass: `rake test`
- Fix any RuboCop violations: `rubocop`

### API Testing Strategy
1. **Unit Tests**: Test individual classes without HTTP calls
2. **Integration Tests**: Test full API workflows with VCR cassettes
3. **Error Handling Tests**: Test all error scenarios (401, 404, 429, 500, etc.)
4. **Configuration Tests**: Test different configuration scenarios
5. **Middleware Tests**: Test Faraday middleware behavior

### VCR Best Practices
VCR records and replays HTTP interactions for deterministic testing.

**Configuration** (`test/support/vcr.rb`):
```ruby
VCR.configure do |c|
  c.cassette_library_dir = "test/vcr_cassettes"
  c.hook_into :webmock
  c.filter_sensitive_data("<API_KEY>") { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_key") }
  c.default_cassette_options = {
    record: :once,
    match_requests_on: [:method, :uri, :body]
  }
end
```

**Usage in tests**:
```ruby
describe "Creators API" do
  it "fetches creator details" do
    VCR.use_cassette("creators/fetch_success") do
      creator = client.creators.find("123")
      assert_equal "John Doe", creator.name
    end
  end

  it "handles not found errors" do
    VCR.use_cassette("creators/not_found") do
      error = assert_raises(ScrapeCreators::NotFoundError) do
        client.creators.find("nonexistent")
      end
      assert_match /not found/i, error.message
    end
  end
end
```

**VCR Cassette Guidelines**:
- Store in `test/vcr_cassettes/` with subdirectories per resource
- Use descriptive names: `creators/fetch_success.yml`, `creators/rate_limit_error.yml`
- Keep cassettes minimal - only necessary request/response data
- Filter sensitive data (API keys, tokens, personal information)
- Commit cassettes to version control for reproducible tests
- Re-record cassettes when API changes: `rm -rf test/vcr_cassettes && rake test`

## Performance Considerations
- Avoid unnecessary object allocation
- Reuse parsed objects (URI, Domain)
- Minimize HTTP requests through caching
- Profile with `minitest/benchmark` when needed

## Common Patterns

### API Client Initialization
```ruby
module ScrapeCreators
  class Client
    attr_reader :api_key, :config

    def initialize(api_key: nil, **options)
      @api_key = api_key || ScrapeCreators.configuration.api_key
      @config = ScrapeCreators.configuration.merge(options)
    end

    def creators
      @creators ||= Resources::Creators.new(self)
    end
  end
end
```

### Response Parsing
```ruby
def parse_response(response)
  case response.status
  when 200..299
    JSON.parse(response.body, symbolize_names: true)
  when 400
    raise BadRequestError, parse_error_message(response)
  when 401
    raise UnauthorizedError, "Invalid API key"
  when 404
    raise NotFoundError, "Resource not found"
  when 429
    raise RateLimitError, "Rate limit exceeded"
  when 500..599
    raise ServerError, "Server error: #{response.status}"
  else
    raise Error, "Unexpected response: #{response.status}"
  end
end
```

### Pagination Handling
```ruby
def list(params = {})
  response = get("/resources", params)
  data = parse_response(response)

  Collection.new(
    items: data[:items].map { |attrs| Resource.new(attrs) },
    next_cursor: data[:next_cursor],
    has_more: data[:has_more]
  )
end
```

### Options Merging
```ruby
DEFAULT_OPTIONS = { /* defaults */ }.freeze

def initialize(uri, options = {})
  @options = DEFAULT_OPTIONS.deep_merge(options)
  # use @options
end
```

### Safe Delegation
```ruby
delegate :method_name, to: :object, allow_nil: true

def custom_method
  @object&.attribute
end
```

## Version Compatibility
- Ruby 3.2+
- Minitest 5.x
- Follow semantic versioning

## API-Specific Guidelines

### ScrapeCreators API
- API documentation: https://docs.scrapecreators.com/introduction
- Base URL: `https://api.scrapecreators.com` (or as configured)
- Authentication: Bearer token via `Authorization` header
- Rate limits: Respect `Retry-After` header on 429 responses
- Response format: JSON with consistent structure
- Error responses: Include error code and descriptive message

### Naming Conventions
- Use Ruby naming conventions for methods (snake_case)
- Map API endpoints to readable method names:
  - `GET /creators` → `client.creators.list`
  - `GET /creators/:id` → `client.creators.find(id)`
  - `POST /creators` → `client.creators.create(attributes)`
  - `PUT /creators/:id` → `client.creators.update(id, attributes)`
  - `DELETE /creators/:id` → `client.creators.delete(id)`

### Request/Response Handling
- Always validate required parameters before making requests
- Convert Ruby conventions (snake_case) to API conventions (camelCase) if needed
- Parse timestamps into Ruby Time/DateTime objects
- Handle pagination consistently across all list endpoints
- Provide helpful error messages that include API error details

### Security Considerations
- Never log or expose API keys in error messages
- Filter sensitive data in VCR cassettes
- Use environment variables for API credentials in tests
- Validate SSL certificates (don't disable SSL verification)
- Sanitize user input before including in requests

## Development Workflow

### Setting Up Development Environment
```bash
# Clone repository
git clone https://github.com/activefx/scrape_creators.git
cd scrape_creators

# Install dependencies
bundle install

# Set up API credentials for testing
export SCRAPE_CREATORS_API_KEY="your_test_api_key"

# Run tests
rake test

# Run console for experimentation
rake console
```

### Making Changes
1. Create a feature branch: `git checkout -b feature/your-feature`
2. Write tests first (TDD approach)
3. Implement the feature
4. Ensure all tests pass: `rake test`
5. Check code style: `rubocop`
6. Update documentation if needed
7. Commit with clear messages
8. Push and create pull request

### Pre-Pull Request Checklist
Before creating a pull request, you **MUST** ensure the following:

1. **RuboCop Must Pass**: Run `rubocop` to check for style violations
   - If RuboCop reports violations, run `rubocop -a` (autocorrect) to automatically fix safe violations
   - Review autocorrected changes to ensure they are correct
   - Manually fix any remaining violations that autocorrect cannot handle
   - Re-run `rubocop` to verify all violations are resolved
   - **DO NOT** create a pull request if RuboCop is failing

2. **All Tests Must Pass**: Run `rake test` to ensure all tests pass

3. **Commit RuboCop Fixes**: If autocorrect made changes, commit them with a clear message:
   ```bash
   git add .
   git commit -m "Fix RuboCop violations"
   ```

**Example workflow before creating PR**:
```bash
# Run RuboCop
rubocop

# If violations are found, run autocorrect
rubocop -a

# Review the changes
git diff

# Commit autocorrect changes if any
git add .
git commit -m "Fix RuboCop violations"

# Verify RuboCop passes
rubocop

# Ensure tests still pass
rake test

# Now safe to create PR
gh pr create --title "Your feature" --body "Description"
```

### Running Tests
```bash
# Run all tests
rake test

# Run specific test file
ruby test/scrape_creators/client_test.rb

# Run tests with verbose output
TESTOPTS="-v" rake test

# Re-record VCR cassettes
rm -rf test/vcr_cassettes && rake test
```

## References
- [ScrapeCreators API Documentation](https://docs.scrapecreators.com/introduction)
- [Faraday Documentation](https://lostisland.github.io/faraday/)
- [Minitest Documentation](https://docs.seattlerb.org/minitest/)
- [Minitest Cheatsheet](https://devhints.io/minitest)
- [VCR Documentation](https://relishapp.com/vcr/vcr/docs)
- [YARD Documentation Guide](https://rubydoc.info/gems/yard/file/docs/GettingStarted.md)
- Project README for usage examples

