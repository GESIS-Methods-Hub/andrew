#!/bin/bash

# Function to check if R is installed
check_r_installed() {
    if command -v R &> /dev/null; then
        echo "R is already installed."
        return 0
    else
        echo "R is not installed."
        return 1
    fi
}

# Function to install R
install_r() {
  #!/bin/bash

  # Define the installation directory
  INSTALL_DIR=$HOME/R

  # Create the installation directory
  echo "Creating installation directory at $INSTALL_DIR..."
  mkdir -p "$INSTALL_DIR"

  # Download R source code
  echo "Downloading R source code..."
  R_VERSION="4.3.1"  # Replace with the desired R version
  wget https://cran.r-project.org/src/base/R-4/R-$R_VERSION.tar.gz -O R.tar.gz

  # Extract the source code
  echo "Extracting R source code..."
  tar -xzf R.tar.gz
  cd R-$R_VERSION

  # Configure and install R locally
  echo "Configuring and installing R locally..."
  ./configure --prefix="$INSTALL_DIR" --without-recommended-packages
  make
  make install

  # Add R to the PATH
  echo "Adding R to PATH..."
  echo "export PATH=$INSTALL_DIR/bin:\$PATH" >> ~/.bashrc
  export PATH=$INSTALL_DIR/bin:$PATH

  # Verify installation
  echo "Verifying R installation..."
  R --version

  # Cleanup
  echo "Cleaning up..."
  cd ..
  rm -rf R-$R_VERSION R.tar.gz

  # Success message
  echo "R installation completed successfully at $INSTALL_DIR."
}

# Main script logic
if ! check_r_installed; then
    install_r
    if check_r_installed; then
        echo "R has been successfully installed."
    else
        echo "Failed to install R. Please check for issues."
        exit 1
    fi
else
    echo "No action needed."
fi
