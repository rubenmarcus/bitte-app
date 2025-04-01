FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    libwebkit2gtk-4.0-dev \
    libgtk-3-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev \
    wget \
    unzip \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Install pnpm
RUN npm install -g pnpm@8

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Android SDK
ENV ANDROID_HOME=/opt/android-sdk
RUN mkdir -p $ANDROID_HOME && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O android-sdk.zip && \
    unzip android-sdk.zip -d $ANDROID_HOME && \
    rm android-sdk.zip

# Install Android SDK components
RUN yes | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --licenses && \
    $ANDROID_HOME/cmdline-tools/bin/sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0" "ndk;25.2.9519653"

# Set Android environment variables
ENV ANDROID_NDK_HOME=$ANDROID_HOME/ndk/25.2.9519653
ENV PATH=$PATH:$ANDROID_HOME/platform-tools

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install

# Copy the rest of the application
COPY . .

# Create a build script
RUN echo '#!/bin/bash\n\
case "$1" in\n\
  "linux")\n\
    pnpm tauri build --target x86_64-unknown-linux-gnu\n\
    ;;\n\
  "windows")\n\
    pnpm tauri build --target x86_64-pc-windows-msvc\n\
    ;;\n\
  "android")\n\
    pnpm tauri android init\n\
    pnpm tauri android build\n\
    ;;\n\
  *)\n\
    echo "Usage: $0 {linux|windows|android}"\n\
    exit 1\n\
    ;;\n\
esac' > /app/build.sh && chmod +x /app/build.sh

# Set the entrypoint to our build script
ENTRYPOINT ["/app/build.sh"]