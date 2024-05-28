
#!/bin/bash

sudo apt-get install -y python3-full python-is-python3 build-essential python3-dev python3-pip

# To setup gstreamer
sudo apt install -y \
    gir1.2-gst-plugins-base-1.0 \
    gir1.2-gstreamer-1.0 \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-tools \
    libcairo2-dev \
    libgirepository1.0-dev \
    python3-gst-1.0

# To use gi in mopidy at runtime
sudo apt-get install -y python3-gi python3-gi-cairo gir1.2-gtk-4.0

# To control audio
sudo apt-get install -y pulseaudio

# Create virtual environment
python -m venv --system-site-packages venv

# Modify activate script
cat <<EOL >> "venv/bin/activate"
alias run='./run.sh'
EOL

source venv/bin/activate

pip install -r requirements.txt

