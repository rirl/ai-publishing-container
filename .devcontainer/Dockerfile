FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

# Install System dependencies, Git LFS, Java (for PlantUML), Graphviz, Pandoc, and curl
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
       git \
       git-lfs \
       ruby-full \
       default-jre \
       graphviz \
       pandoc \
       plantuml \
       curl \
       cargo \
       build-essential \
       pkg-config \
       libssl-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Latest Supported Ruby Gems for PDF, DOCX, and Diagrams
RUN gem install \
                asciidoctor \
                asciidoctor-diagram \
                asciidoctor-pdf \
                asciidoctor-diagram-plantuml \
                rouge

# Use vscode's cargo home so binaries are available to the remote user
ENV HOME=/home/vscode
ENV CARGO_HOME=/home/vscode/.cargo
ENV PATH="/home/vscode/.cargo/bin:${PATH}"

RUN mkdir -p /home/vscode/.cargo/bin \
    && chown -R vscode:vscode /home/vscode/.cargo

# Install aichat CLI for unified access to ChatGPT, Claude, and Gemini
RUN cargo install aichat

# Verify aichat installation
RUN aichat --version

