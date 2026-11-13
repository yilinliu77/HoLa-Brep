> **Origin and license**
>
> The code in this folder is adapted from the [evaluation scripts of GET3D](https://github.com/nv-tlabs/GET3D/tree/master/evaluation_scripts)
> (Copyright (c) 2022, NVIDIA Corporation & affiliates) and is distributed under the
> [NVIDIA Source Code License for GET3D](./LICENSE.txt), **not** under the GPL-3.0 license that covers the rest of
> this repository. It may only be used non-commercially, i.e., for research or evaluation purposes.
> Modifications made for HoLa-Brep remain under the same license.
>
> The light field descriptor data and executables in `load_data/` (`3DAlignment_v1.8.exe`, `glut32.dll`, `q8_table`,
> `align10.txt`, `12_*.OBJ`) come from the [official LFD repository](https://github.com/Sunwinds/ShapeDescriptor),
> and `compute_lfd_feat/lfd_me.py` builds on [light-field-distance](https://github.com/kacperkan/light-field-distance).
> They remain subject to the terms of their original authors.
>
> The original GET3D README follows below.

## Scripts for Evaluating GET3D

#### Compute Light Field Distance

We thanks the authors for releasing the source code of
LFD [official repo](https://github.com/Sunwinds/ShapeDescriptor) and
It's [python extension](https://github.com/kacperkan/light-field-distance).

- Step 0: Download the all the files
  from [official repo](https://github.com/Sunwinds/ShapeDescriptor/tree/master/LightField/3DRetrieval_v1.8/3DRetrieval_v1.8/Executable)
  , and save it into `evaluation_scripts/load_data`.
- Step 1: Compile the files for light fild distance

```bash
cd evaluation_scripts/load_data
bash do_all.sh
cd ../..
git clone https://github.com/kacperkan/light-field-distance
cd light-field-distance
bash compile.sh
python setup.py install
cd ..
```

- Step 2: To compute LFD on a server, we need to set up a dummy screen

```bash
apt-get install -y freeglut3 libglu1-mesa xserver-xorg-video-dummy
X -config evaluation_scripts/compute_lfd_feat/dummy-1920x1080.conf
```

- Step 3: On a separate console, `export DISPLAY=:0`

- Step 4: We first generat the Light Field feature for each object by running

```bash
 python compute_lfd_feat_multiprocess.py --gen_path PATH_TO_THE_MODEL_PREDICTION --save_path PATH_FOR_LFD_OUTPUT_FOR_PRED
```

- Step 5: Do the same for the ground truth data

```bash 
 python compute_lfd_feat_multiprocess.py --gen_path PATH_TO_GT_MODEL  --save_path PATH_FOR_LFD_OUTPUT_FOR_GT
```

- Step 6: Compute the metric: LFD

```bash
python compute_lfd.py --split_path PATH_TO_TEST_SPLIT  --dataset_path PATH_FOR_LFD_OUTPUT_FOR_GT --gen_path PATH_FOR_LFD_OUTPUT_FOR_PRED --save_name results/our/lfd.pkl
```

### Compute Chamfer Distance

- Step 1: Download original shapenet obj files from Shapenet Webpage
- Step 2: Running scripts to compute the chamfer distance

```bash
python compute_cd.py --dataset_path PATH_TO_GT_OBJS --gen_path PATH_TO_THE_MODEL_PREDICTION --split_path PATH_TO_TEST_SPLIT --save_name results/our/cd.pkl
```

(Optional) For shapenet car, since the GT dataset contains intern structures, we thus only
sample the points from the outer surface of the object for both our prediction and ground
truth. To achieve this:

```bash
python sample_surface.py  --n_points 5000 --n_proc 2 --shape_root PATH_TO_OBJS  --save_root PATH_TO_THE_SAMPLE_POINTS
```

### Compute Cov and MMD score:

After compute the chamfer distance and LFD, to compute the Coverage score and MMD score:

```bash
python  compute_cov_mmd.py
```
