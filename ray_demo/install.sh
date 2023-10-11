# Install before python
sudo apt-get install gpg-agent -y

# Install Python: https://www.linuxcapable.com/install-python-3-8-on-ubuntu-linux/
sudo apt install python3.9-distutils python3.9 -y


# Install pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3.9 get-pip.py


export PATH=$PATH:/home/ubuntu/.local/bin

# Install ray
pip install -U "ray[default]"

pip install torch torchvision torchaudio tqdm pandas
pip install "ray[train]"
pip install "ray[tune]"


# Start ray cluster
ray start --head --port=6379 --dashboard-host=0.0.0.0
ray start --address=192.168.10.129:6379

mkdir ray
cd ray
vi mnist.py