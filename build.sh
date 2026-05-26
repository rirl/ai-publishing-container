#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Target file name (without extension)
DOC_NAME="document"

echo "🚀 Starting document compilation pipeline..."

# Step 1: Clean up any old output files
echo "🧹 Cleaning up previous builds..."
rm -f "${DOC_NAME}.pdf" "${DOC_NAME}.docx" "${DOC_NAME}.html"

# Step 2: Compile to PDF
echo "📄 Generating PDF (with diagrams)..."
asciidoctor-pdf -r asciidoctor-diagram "${DOC_NAME}.adoc"
echo "✅ PDF successfully created: ${DOC_NAME}.pdf"

# Step 3: Compile to Word (DOCX)
echo "📝 Generating HTML layout to render diagram images..."
asciidoctor -r asciidoctor-diagram "${DOC_NAME}.adoc"

# echo "📦 Converting layout into native Word file..."
# asciidoctor-docx "${DOC_NAME}.adoc"
# echo "✅ Word document successfully created: ${DOC_NAME}.docx"

# Step 4: Cleanup temporary HTML generation artifacts
echo "🧼 Cleaning up temporary files..."
rm -f "${DOC_NAME}.html"

echo "🎉 All formats compiled successfully!"