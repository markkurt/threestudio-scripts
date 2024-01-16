# ThreeStudio Scripts
Scripts to assist running [threestudio](https://github.com/threestudio-project/threestudio) and [dreamcraft3d](https://github.com/DSaurus/threestudio-dreamcraft3D) on cloud servers.

## Using Linux Cloud Resources
while it can work with <40MB of VRAM, I have had some runs that failed due to out of memory.  The `1x A6000 (48 GB VRAM)` for $0.80/hr at [Labda Labs](https://cloud.lambdalabs.com/instances) has consistently performed well.  Taking a about 3 hours to do a complete run.

Generally these scripts should work on hosts with Ubuntu 22.04 LTS

## Running Threestudio
- login to machine via ssh, will need sudo access

- clone the repo to your working directory

- copy `.env.example` to `.env` - `cp .env.example .env`
-- there are two environment variables set in the .env - neither are used automatically, but they can be helpful to have available inside the docker container.  The DOCKER_HUB_TOKEN should only be needed if you are rebuilding the container.  The HUGGINGFACE_CLI_TOKEN will be needed to login to huggingface which is required to run the models.  It can be found under your [account](https://huggingface.co/settings/tokens)

- run `sudo ./setup.sh`
at the very end of the output, check to make sure that the correct runtime is being used.  It should say `nvidia` somewhere in the last 10 lines or so.
```
 Runtimes: nvidia runc io.containerd.runc.v2 io.containerd.runtime.v1.linux
 Default Runtime: nvidia
 ```

- the last step in setup will download zero123-xl via wget, if you want to use the more advanced stable-123 then download from huggingface.  If you are going to download, then you can CTRL-C out of the download of zero123-xl

- optional: download [stable-zero123](https://huggingface.co/stabilityai/stable-zero123) from hugging face.  rename the file to `stable_zero123.ckpt` and put in the `load/zero123` directory under `threestudio`

- open an interactive shell to the container by running `./interactive.sh` (the first time this will require downloading the docker image)
if you get an error that docker isn't running you can use:
```
sudo systemctl restart docker
sudo systemctl daemon-reload
```
to restart docker and then run: `sudo docker info | grep -i runtime` to verify that docker is running with the nvidia runtime

### the following commands are run within the vm

- activate the virtual environment by running `. venv/bin/activate` in the root directory

- run `huggingface-cli login` and copy in the token from the hugging face account tokens

- change directory in to threestudio

- at this point you should be able to run the command from the quickstart for threestudio:
```
python launch.py --config configs/dreamfusion-if.yaml --train --gpu 0 system.prompt_processor.prompt="a zoomed out DSLR photo of a baby bunny sitting on top of a stack of pancakes"
```

- you can also run the dreamcraft3d examples
```
# It will take about 3 hours and ~22G GPU memory to run all stages
prompt="a delicious hamburger"
image_path="load/images/hamburger_rgba.png"

# --------- Stage 1 (NeRF & NeuS) --------- #
python launch.py --config custom/threestudio-dreamcraft3D/configs/dreamcraft3d-coarse-nerf.yaml --train system.prompt_processor.prompt="$prompt" data.image_path="$image_path"

ckpt=outputs/dreamcraft3d-coarse-nerf/$prompt@LAST/ckpts/last.ckpt
python launch.py --config custom/threestudio-dreamcraft3D/configs/dreamcraft3d-coarse-neus.yaml --train system.prompt_processor.prompt="$prompt" data.image_path="$image_path" system.weights="$ckpt"

# --------- Stage 2 (Geometry Refinement) --------- #
ckpt=outputs/dreamcraft3d-coarse-neus/$prompt@LAST/ckpts/last.ckpt
python launch.py --config custom/threestudio-dreamcraft3D/configs/dreamcraft3d-geometry.yaml --train system.prompt_processor.prompt="$prompt" data.image_path="$image_path" system.geometry_convert_from="$ckpt"


# --------- Stage 3 (Texture Refinement) --------- #
ckpt=outputs/dreamcraft3d-geometry/$prompt@LAST/ckpts/last.ckpt
python launch.py --config custom/threestudio-dreamcraft3D/configs/dreamcraft3d-texture.yaml --train system.prompt_processor.prompt="$prompt" data.image_path="$image_path" system.geometry_convert_from="$ckpt"
```

the ckpt environment variable needs to be updated each time, at the end of each stage the directory used for checkpoints is printed to the console, you can use that directory for each subsequent run.

- you can use the commands from dreamcraft3d to export a mesh
```
prompt="a delicious hamburger"
image_path="load/images/hamburger_rgba.png"
ckpt=path/to/last.ckpt
python launch.py --config custom/threestudio-dreamcraft3D/configs/dreamcraft3d-YOURSTAGE.yaml --export system.prompt_processor.prompt="$prompt" data.image_path="$image_path" resume="$ckpt" system.exporter.context_type=cuda
```

the checkpoint used to export the mesh should be the checkpoint for the texture refinement stage

## Versions
- this has been tested and works with ref `256c9a7` of [dreamcraft3d](https://github.com/DSaurus/threestudio-dreamcraft3D) and ref `9807fc5` of [threestudio](https://github.com/threestudio-project/threestudio) although the setup script will pull the latest of both projects

 