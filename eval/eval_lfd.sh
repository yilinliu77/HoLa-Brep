if [ -z "$TYPE" ]; then
  echo "Error: 'CONDITION' variable is not set."
  exit 1
fi

cd ./eval/lfd/evaluation_scripts/compute_lfd_feat
python -m compute_lfd_feat_multiprocess --gen_path ../../../../outputs/${TYPE}_post --save_path ../../../../outputs/${TYPE}_lfd --prefix recon_brep.stl 
cd ..
python -m compute_lfd --dataset_path /mnt/d/img2brep/brepgen_train_lfd_feat --gen_path ../../../outputs/${TYPE}_lfd --save_name ../../../outputs/${TYPE}_lfd.pkl --num_workers 8 --list ../../../data/data_index/deduplicated_deepcad_training_7_30.txt 
cd ../../..
python -m eval.viz_lfd ${TYPE}_lfd.pkl ${TYPE}_lfd.png