# Prepare Machine
## Install before python
```
sudo apt-get install gpg-agent git -y
sudo add-apt-repository ppa:deadsnakes/ppa -y

sudo apt update
sudo apt-get upgrade -y
```

## (Optional) Install `oh-my-zsh` and `zsh-autosuggestion`
```
# https://github.com/ohmyzsh/ohmyzsh?tab=readme-ov-file#basic-installation
# https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md#oh-my-zsh
sudo apt-get install zsh -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

### Add the plugin to the list of plugins for Oh My Zsh to load (inside ~/.zshrc):
```bash
plugins=( 
    # other plugins...
    zsh-autosuggestions
)
```

```
source ~/.zshrc
```
## Install Python: https://www.linuxcapable.com/install-python-3-8-on-ubuntu-linux/
```
sudo apt install python3.10 python3-distutils -y

## Install pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3.10 get-pip.py
```

## Make `zsh` your default shell

```
chsh -s $(which zsh)
```

## Modify Path
```
echo "export PATH=$PATH:/home/ubuntu/.local/bin" >> ~/.bashrc
source ~/.bashrc
```

```
echo "export PATH=$PATH:/home/ubuntu/.local/bin" >> ~/.zshrc
source ~/.zshrc
```

## Clone repo
```
git clone https://github.com/data-max-hq/cost-effective-ml.git
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

## Ports
* 8888 Jupyter Lab
* 8265 Ray UI
* 6006 Tensorboard
