#!/bin/bash

# HeyMax Analytics Stack Setup Script

set -e

echo "🚀 Setting up HeyMax Analytics Stack with Dagster..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "📝 Creating .env file from template..."
    cp .env.example .env
    echo "✅ .env file created. Please edit it with your GCP credentials."
else
    echo "✅ .env file already exists."
fi

# Check for service account key
if [ ! -f "service-account-key.json" ]; then
    echo "⚠️  Please place your GCP service account key as 'service-account-key.json'"
    echo "   You can download it from the Google Cloud Console."
fi

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p data/
mkdir -p dagster_home/
mkdir -p dbt/target/

# Copy sample data if no CSV files exist
if [ ! -f "data/*.csv" ]; then
    echo "📄 No CSV files found in data/ directory."
    echo "   Place your event_stream.csv file in the data/ directory."
fi

# Build Docker containers
echo "🔨 Building Docker containers..."
docker-compose build

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit .env file with your GCP credentials"
echo "2. Place service-account-key.json in the root directory" 
echo "3. Copy your CSV files to the data/ directory"
echo "4. Run 'make up' or 'docker-compose up -d' to start the stack"
echo "5. Open http://localhost:3000 in your browser to access Dagster UI"
echo ""
echo "Available commands:"
echo "  make up     - Start the analytics stack"
echo "  make down   - Stop the analytics stack"
echo "  make logs   - View logs"
echo "  make help   - Show all available commands"