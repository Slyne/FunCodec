import argparse
import os


def load_wavscp(wavscp):
    wavscp_dict = {}
    with open(wavscp, 'r') as f:
        for line in f:
            key, path = line.split()
            wavscp_dict[key] = path
    return wavscp_dict

def move_reconstructed_wav(input_wav_scp, org_prefix_dir, cur_prefix_dir, recon_wavs_dir):
    input_wav = load_wavscp(input_wav_scp)
    os.makedirs(cur_prefix_dir, exist_ok=True)
    num_files_moved = 0
    for root, dirs, files in os.walk(recon_wavs_dir):
        for file in files:
            if file.endswith('.wav'):
                file_path = os.path.join(root, file)
                file_path = os.path.abspath(file_path)
                key = file.replace('.wav', '')
                org_path = input_wav[key]
                target_path = org_path.replace(org_prefix_dir, cur_prefix_dir)
                os.makedirs(os.path.dirname(target_path), exist_ok=True)
                os.rename(file_path, target_path)
                num_files_moved += 1
                
    print(f'Done! moved {num_files_moved} files.')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Move reconstructed wavs to the original directory')
    parser.add_argument('--input_wav_scp', type=str, help='input wav.scp file')
    parser.add_argument('--org_prefix_dir', type=str, help='original prefix directory')
    parser.add_argument('--cur_prefix_dir', type=str, help='current prefix directory')
    parser.add_argument('--recon_wavs_dir', type=str, help='reconstructed wavs directory')
    args = parser.parse_args()
    move_reconstructed_wav(args.input_wav_scp, args.org_prefix_dir, args.cur_prefix_dir, args.recon_wavs_dir)