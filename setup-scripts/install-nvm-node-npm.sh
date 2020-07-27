wget https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh -O nvm-install.sh

sudo bash nvm-install.sh
bash nvm-install.sh

source .nvm/nvm.sh

sudo su - -c 'nvm i v10.21'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm i v10.21


