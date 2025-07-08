import os
import shutil


def create_config_folder(common_dir, target_dir):

    os.makedirs(target_dir, exist_ok=True)

    for file in os.listdir(common_dir):
        src_path = os.path.join(common_dir, file)
        trgt_path = os.path.join(target_dir, file)
        shutil.copy2(src_path, trgt_path)
