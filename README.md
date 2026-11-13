# HoLa: B-Rep Generation using a Holistic Latent Representation

[![arXiv](https://img.shields.io/badge/📃-arXiv%20-red.svg)](https://arxiv.org/abs/2504.14257)

*Yilin Liu, Duoteng Xu, Xingyao Yu, Xiang Xu, Daniel Cohen-Or, Hao Zhang, Hui Huang*

<p align="center">
    <img src="./figs/teaser.jpg" alt="HoLa-Brep" style>
</p>

> This repository is for the HoLa-Brep project. Given a B-rep model which consists of surfaces, (half-) curves and vertices, we design a novel holistic latent representation (HL-Rep) to encode both the continuous geometric properties over all primitives and their discrete topological relationships into one holistic latent space. Compared with existing methods, primitives in the holistic latent space are intrinsically consistent, which enables a more accurate and expressive B-rep generation.

# Experiments
## Preparation⚙️
### 1. Environment
#### 🌟**Run with Docker**(Recommended)🌟
Build the Docker image:

```
docker build -t hola-brep .
```
> Some errors may occur when installing `pointnet2_ops_lib` while building the image. You may find a solution to these issues [here](./pointnet2_ops_lib/Possible_solution.md).

#### **Run locally**
We built the project in a **Linux** environment.

1. Install Linux dependencies:
```
apt update
apt install libgl-dev
apt install freeglut3 freeglut3-dev libosmesa6-dev libglu1-mesa-dev libglu1-mesa xserver-xorg-video-dummy
```

2. Create the environment with **Conda**:
```
conda env create -f environment.yml
conda activate HoLa-Brep
```

### 2. Checkpoints

Pre-trained checkpoints are available on **[Hugging Face](https://huggingface.co/YuXingyao/HoLa-Brep/tree/main)**, including the following checkpoints:

| Checkpoint                            | Description                                                   |
| ------------------------------------- | ------------------------------------------------------------- |
| AE_ABC_1100k.ckpt                     | Autoencoder pre-trained on ABC dataset                        |
| AE_deepcad_1100k.ckpt                 | Autoencoder pre-trained on deepcad dataset                    |
| Diffusion_uncond_1100k.ckpt           | Pre-trained unconditional latent diffusion model              |
| Diffusion_mvr_sq30_800k.ckpt          | Pre-trained multi-image-conditioned latent diffusion model    |
| Diffusion_pc_sq30_1600k.ckpt          | Pre-trained point-conditioned latent diffusion model          |
| Diffusion_pc_sq30_noisy_2300k.ckpt    | Pre-trained point-conditioned latent diffusion model for noisy point clouds |
| Diffusion_sketch_sq30_1500k.ckpt      | Pre-trained sketch-conditioned latent diffusion model         |
| Diffusion_svr_sq30_1500k.ckpt         | Pre-trained single-image-conditioned latent diffusion model   |
| Diffusion_txt_sq30_1000k.ckpt         | Pre-trained text-conditioned latent diffusion model           |

If you are running the project locally, please download the checkpoints (~30 GB in total) into the `ckpt` folder under the **root folder**, e.g., within the `HoLa-Brep` environment:
```
python -c "from huggingface_hub import snapshot_download; snapshot_download('YuXingyao/HoLa-Brep', local_dir='ckpt', allow_patterns='*.ckpt')"
```

### 3. Data

The test data (the 2,424-model DeepCAD test split, ~9 GB zipped) is available on **[Hugging Face](https://huggingface.co/datasets/YuXingyao/HoLa-BRep/tree/main)**. Download `data.zip` and extract it into the `data` folder under the **root folder**, e.g., within the `HoLa-Brep` environment:
```
python -c "from huggingface_hub import hf_hub_download; hf_hub_download('YuXingyao/HoLa-BRep', 'data.zip', repo_type='dataset', local_dir='data')"
unzip data/data.zip -d data
```
It contains two folders: `organized_data` and `data_index`.

+ `organized_data` contains the necessary data for conditioned generation, as well as the model itself.

```
organized_data
|-- 00000093
|   |-- data.npz
|   |-- img_feature_dinov2.npy
|   |-- imgs.npz
|   |-- normalized_shape.step
|   |-- pc.ply
|   |-- text.txt
|   `-- text_feat.npy
|...
```
+ `data_index` holds the index file of the test split (`deduplicated_deepcad_testing_7_30.txt`).

Only the test split is released; the training/validation data and the light-field-distance features (`data_lfd_feat`) are not included. Please refer to the [dataset card](https://huggingface.co/datasets/YuXingyao/HoLa-BRep) for checksums, known issues, and the licenses of the underlying data (DeepCAD and Text2CAD).

### 4. **Preparation check**
If you are running the project **locally**, the project folder structure should now look as follows:
```
HoLa-Brep
|-- ckpt
|   |-- AE_ABC_1100k.ckpt
|   |-- AE_deepcad_1100k.ckpt
|   |-- Diffusion_mvr_sq30_800k.ckpt
|   |-- Diffusion_pc_sq30_1600k.ckpt
|   |-- Diffusion_pc_sq30_noisy_2300k.ckpt
|   |-- Diffusion_sketch_sq30_1500k.ckpt
|   |-- Diffusion_svr_sq30_1500k.ckpt
|   |-- Diffusion_txt_sq30_1000k.ckpt
|   `-- Diffusion_uncond_1100k.ckpt
|-- data
|   |-- data_index
|   `-- organized_data
|-- diffusion
|-- eval
|-- ...
```

If you are using **Docker** for the project, further details will be provided in the next steps.


## Generation 🪄
### **Local**
To generate B-Rep models, you can use the following commands:

```
export TYPE="your_intended_method_of_generation"
bash scripts/generate_${TYPE}.sh
```
Please export `TYPE` using one of the following options:
+ `pc`, `txt`, `sketch`, `svr` or `mvr` for conditioned generation.
+ `unconditional` for unconditional generation.

### **Docker**🐋
If you are using **Docker**, you can generate models after the `hola-brep` image is successfully built with this command:

```
export TYPE="your_intended_method_of_generation"
docker run --rm -it \
    --gpus all \
    --name hola-brep \
    --shm-size=24g \
    -p 8080:8080 \
    -v /path/to/your/host/output/folder:/HoLa-Brep/outputs \
    -v /path/to/your/host/data/folder:/HoLa-Brep/data \
    -v /path/to/your/host/checkpoint/folder:/HoLa-Brep/ckpt \
    hola-brep \
    bash scripts/generate_${TYPE}.sh
```
The available options for `TYPE` are the same as mentioned previously. For example, for unconditional generation:
```
docker run --rm -it \
    --gpus all \
    --name hola-brep \
    -p 8080:8080 \
    -v /path/to/your/host/output/folder:/HoLa-Brep/outputs \
    -v /path/to/your/host/data/folder:/HoLa-Brep/data \
    -v /path/to/your/host/checkpoint/folder:/HoLa-Brep/ckpt \
    hola-brep \
    bash scripts/generate_unconditional.sh
```

> If you encounter issues with loading DINOv2, please manually **[download](https://dl.fbaipublicfiles.com/dinov2/dinov2_vitl14/dinov2_vitl14_reg4_pretrain.pth)** the model and mount it into the container by adding the following option to the `docker run` command (before the image name `hola-brep`):
> ```
> -v /path/to/dinov2_vitl14_reg4_pretrain.pth:/root/.cache/torch/hub/checkpoints/dinov2_vitl14_reg4_pretrain.pth
> ```


## Post-Process🪚
After generation, the output is converted into a watertight CAD model through post-processing:
```
export TYPE="generation_type"
bash scripts/postprocess.sh
```
The available options for `TYPE` are the same as mentioned previously.

You can find model folders containing a `.step` file in the `outputs/${TYPE}_post` folder.

# Evaluation🧮
### 1. Unconditional
To evaluate unconditional results:
```
bash eval/eval_uncond.sh
```

### 2. Conditioned
To evaluate conditioned results:

1. Export the condition name
```
export TYPE="generation_type"
```
`TYPE` can be `pc`, `txt`, `sketch`, `svr` or `mvr` as stated previously.

2. Execute the script
```
bash eval/eval_cond.sh
```
You can find the evaluation results in the `outputs` folder as well.

### 3. LFD

1. Compile the files for light field distance
```
cd eval/lfd/evaluation_scripts/load_data
bash do_all.sh
cd ../..
git clone https://github.com/kacperkan/light-field-distance
cd light-field-distance
bash compile.sh
python setup.py install
cd ..
```

2. To calculate LFD, we need a virtual display to render objects:
```
X -config evaluation_scripts/compute_lfd_feat/dummy-1920x1080.conf
```
3. To access the virtual display, point to it in a **new terminal**:
```
export DISPLAY=:0
```

4. Return to the root directory and specify the generation `TYPE` you want to evaluate:
```
cd ../..
export TYPE=""
bash eval/eval_lfd.sh
```

You can check the visualized LFD result in the `outputs` folder.


# Citation📃
If you find our project useful, please consider starring our repo and citing our paper:
```bibtex
@article{liu2025hola,
  title     = {HoLa: B-Rep Generation using a Holistic Latent Representation},
  author    = {Liu, Yilin and Xu, Duoteng and Yu, Xingyao and Xu, Xiang and Cohen-Or, Daniel and Zhang, Hao and Huang, Hui},
  journal   = {ACM Transactions on Graphics},
  volume    = {44},
  number    = {4},
  pages     = {1--25},
  year      = {2025},
  publisher = {Association for Computing Machinery},
  doi       = {10.1145/3730842}
}
```

# License
This project is released under the [GPL-3.0 License](./LICENSE), except for the light field distance evaluation code in [`eval/lfd/evaluation_scripts`](./eval/lfd/evaluation_scripts), which is adapted from [GET3D](https://github.com/nv-tlabs/GET3D) and remains under the [NVIDIA Source Code License for GET3D](./eval/lfd/evaluation_scripts/LICENSE.txt) (non-commercial use only). See [its README](./eval/lfd/evaluation_scripts/README.md) for details.
