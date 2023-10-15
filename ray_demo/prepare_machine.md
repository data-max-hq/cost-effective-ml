# Prepare Machine
## Install before python
```
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install gpg-agent git -y

sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update

## Install Python: https://www.linuxcapable.com/install-python-3-8-on-ubuntu-linux/
sudo apt install python3.9-distutils python3.9 -y

## Install pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3.9 get-pip.py
```

## Modify Path
```
export PATH=$PATH:/home/ubuntu/.local/bin
```

## Install ray and dependencies
```
pip install torch torchvision torchaudio tqdm pandas
pip install "ray[default]"
pip install "ray[train]"
pip install "ray[tune]"
pip install tensorboard
pip install ipywidgets
pip install jupyterlab
pip install notebook
```
or
```commandline
pip install -r requirements.txt
```
