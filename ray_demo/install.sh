# Install before python
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install gpg-agent git -y

sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update

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
pip install notebook

pip install jupyterlab
jupyter lab

pip install notebook
jupyter notebook --ip 0.0.0.0

# Start ray cluster
ray start --head --port=6379 --dashboard-host=0.0.0.0
ray start --address=192.168.11.161:6379

git clone https://github.com/data-max-hq/cost-effective-ml.git

mkdir ray
cd ray
vi mnist.py

RAY_ADDRESS='http://192.168.11.161:8265' ray job submit --working-dir . -- python3.9 mnist.py