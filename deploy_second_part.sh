#! /bin/bash

PORT=22005
MACHINE=paffenroth-23.dyn.wpi.edu
HF_TOKEN=$(cat HF_TOKEN.txt)

# Change to the temporary directory
cd tmp

# Add the key to the ssh-agent
eval "$(ssh-agent -s)"
ssh-add mykey

# check that the code in installed and start up the product
COMMAND="ssh -i mykey -p ${PORT} -o StrictHostKeyChecking=no student-admin@${MACHINE}"
${COMMAND} "ls CS553-MLOps-pt2"
${COMMAND} "wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh"
${COMMAND} "bash ~/miniconda.sh -b -p \$HOME/miniconda"
${COMMAND} "export PATH=\$HOME/miniconda/bin:\$PATH && ~/miniconda/bin/conda init bash"
${COMMAND} "export PATH=\$HOME/miniconda/bin:\$PATH && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main"
${COMMAND} "export PATH=\$HOME/miniconda/bin:\$PATH && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r"
${COMMAND} "export PATH=\$HOME/miniconda/bin:\$PATH && conda create -y -n ds553_env python=3.10"
${COMMAND} "export PATH=\$HOME/miniconda/bin:\$PATH && source ~/miniconda/bin/activate ds553_env && pip install -r CS553-MLOps-pt2/requirements.txt && hf auth login --token ${HF_TOKEN} --add-to-git-credential" 
echo "Logging into HuggingFace..."
#${COMMAND} "huggingface-cli login --token ${HF_TOKEN} --add-to-git-credential"
#${COMMAND} "hf auth login --token ${HF_TOKEN} --add-to-git-credential"
${COMMAND} "export PATH=\$HOME/miniconda/bin:\$PATH && export HF_TOKEN=${HF_TOKEN} && source ~/miniconda/bin/activate ds553_env && cd CS553-MLOps-pt2/src && nohup python app.py > log.txt 2>&1 &"
echo "Done"

