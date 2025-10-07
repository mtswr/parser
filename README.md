# Email Parser Application

A Rails application that processes email files (.eml) to extract customer information and stores it in a database. The application uses background job processing with Sidekiq and Redis for handling email parsing asynchronously.

## Features

- **Email Upload**: Upload .eml files through a web interface
- **Background Processing**: Emails are processed asynchronously using Sidekiq
- **Customer Management**: View and manage extracted customer data
- **Processing Logs**: Track success and failure of email processing
- **UI**: Bootstrap-based interface

## Technology Stack

- **Ruby**: 3.2.0
- **Rails**: 8.0.3
- **Database**: PostgreSQL
- **Background Jobs**: Sidekiq
- **Cache/Queue**: Redis
- **Frontend**: Bootstrap 5.3
- **Testing**: RSpec
- **Containerization**: Docker & Docker Compose

## Prerequisites

- Docker and Docker Compose
- Git

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd rails-test
```

### 2. Start the Application

```bash
# Start all services (Rails app, PostgreSQL, Redis, Sidekiq)
docker-compose up --build

# Or run in detached mode
docker-compose up --build -d
```

### 3. Set Up the Database

```bash
# Run database migrations
docker-compose exec web rails db:create db:migrate

# Seed the database (optional)
docker-compose exec web rails db:seed
```

### 4. Access the Application

- **Web Application**: http://localhost:3000

## Usage

### Uploading Emails

1. Navigate to the "Upload Email" page
2. Select a .eml file from your computer
3. Click "Upload Email"
4. The email will be processed in the background
5. Check the "Email Logs" page to see processing status

### Viewing Customers

1. Go to the "Customers" page
2. View all extracted customer information
3. Filter by source if needed
4. Click on individual customers for detailed view

### Monitoring Processing

1. Visit the "Email Logs" page
2. See all email processing attempts
3. Filter by status (success, failed, processing)
4. View detailed error messages for failed processing

## Development

### Running Tests

```bash
# Run all tests
docker-compose exec web bundle exec rspec

# Run specific test file
docker-compose exec web bundle exec rspec spec/models/customer_spec.rb

# Run tests with coverage
docker-compose exec web bundle exec rspec --format documentation
```

### Database Console

```bash
# Access Rails console
docker-compose exec web rails console

# Access PostgreSQL directly
docker-compose exec db psql -U postgres -d email_parser_development
```

### Viewing Logs

```bash
# View application logs
docker-compose logs web

# View Sidekiq logs
docker-compose logs sidekiq

# Follow logs in real-time
docker-compose logs -f web
```

## Architecture

### Models

- **Customer**: Stores extracted customer information
- **EmailLog**: Tracks email processing status and results
- **EmailUpload**: Form object for handling file uploads

### Services

- **EmailParserService**: Parses .eml files and extracts customer data

### Jobs

- **EmailProcessingJob**: Background job for processing emails

### Controllers

- **HomeController**: Dashboard with statistics
- **EmailsController**: Handles email uploads
- **CustomersController**: Manages customer data
- **EmailLogsController**: Shows processing logs

## Email Format Support

The application supports emails from different sources with specific parsing patterns:

### Customer A
- Extracts: Name, Email, Phone, Product Code
- Pattern: Portuguese language format

### Customer B
- Extracts: Name, Email, Phone, Product Code
- Pattern: Portuguese language format

### Generic
- Fallback parser for unknown sources
- Attempts to extract standard fields

## Configuration

### Environment Variables

- `DATABASE_URL`: PostgreSQL connection string
- `REDIS_URL`: Redis connection string
- `RAILS_ENV`: Rails environment (development, test, production)

### Sidekiq Configuration

Sidekiq is configured to use Redis for job queuing. The configuration can be found in `config/initializers/sidekiq.rb`.

### Log Locations

- Application logs: `log/development.log`
- Sidekiq logs: Available via `docker-compose logs sidekiq`
- Database logs: Available via `docker-compose logs db`
